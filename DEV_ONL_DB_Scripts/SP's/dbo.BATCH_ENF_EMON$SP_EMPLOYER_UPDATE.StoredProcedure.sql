/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_EMPLOYER_UPDATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	: BATCH_ENF_EMON$SP_EMPLOYER_UPDATE
Programmer Name : IMP Team
Description		: This is used to modify employer details as per NMSN System Response.
Frequency		: 
Developed On	: 01/05/2012
Called By		: BATCH_ENF_EMON$SP_SYSTEM_UPDATE
Called On	    : BATCH_COMMON$SP_EMPLOYER_UPDATE
--------------------------------------------------------------------------------------------------------------------
Modified BY		:
Modified On		:
Version No		: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_EMPLOYER_UPDATE] (
 @An_Case_IDNO                NUMERIC(6),
 @An_MemberMci_IDNO           NUMERIC (10),
 @Ac_Subsystem_CODE           CHAR(2),
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_ActivityMinor_CODE       CHAR(5) = '',
 @Ac_ReasonStatus_CODE        CHAR(2) = '',
 @Ac_TypeOthpSource_CODE      CHAR(4),
 @An_OthpSource_IDNO          NUMERIC(10),
 @Ac_Reference_ID			  CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_WorkerUpdate_ID          CHAR(30),
 @Ad_Run_DATE                 DATE,
 @Ac_Process_ID				  CHAR(10),	
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE @Lc_StatusSuccess_CODE					CHAR(1)			= 'S',
		  @Lc_StatusFailed_CODE						CHAR(1)			= 'F',
		  @Lc_Space_TEXT							CHAR(1)			= ' ',
		  @Lc_LimitCcpaYes_INDC						CHAR(1)			= 'Y',
		  @Ls_Routine_TEXT							VARCHAR(60)		= 'BATCH_ENF_EMON$SP_EMPLOYER_UPDATE';
		  
  DECLARE @Li_Error_NUMB							INT,
          @Li_ErrorLine_NUMB						INT,
          @Ln_IncomeGross_AMNT						NUMERIC(11, 2),
		  @Ln_IncomeNet_AMNT						NUMERIC(11, 2),
		  @Ln_CostInsurance_AMNT					NUMERIC(11, 2),
		  @Lc_Status_CODE							CHAR(1),
          @Lc_FreqIncome_CODE						CHAR(1),
		  @Lc_FreqPay_CODE							CHAR(1),
		  @Lc_EmployerPrime_INDC					CHAR(1),
		  @Lc_InsProvider_INDC						CHAR(1),
		  @Lc_DpCovered_INDC						CHAR(1),
		  @Lc_DpCoverageAvlb_INDC					CHAR(1),
		  @Lc_FreqInsurance_CODE					CHAR(1),
		  @Lc_InsReasonable_INDC					CHAR(1),
		  @Lc_TypeIncome_CODE						CHAR(2),
		  @Lc_SourceLocConf_CODE					CHAR(3),
		  @Lc_SourceLoc_CODE						CHAR(3),
		  @Lc_DescriptionOccupation_TEXT			CHAR(32),
		  @Ls_Sql_TEXT								VARCHAR(300)	= '',
          @Ls_Sqldata_TEXT							VARCHAR(3000),
          @Ls_DescriptionError_TEXT					VARCHAR(4000),
          @Ld_EndEmployment_DATE					DATE,
		  @Ld_EligCoverage_DATE						DATE,
		  @Ld_PlsLastSearch_DATE					DATE,	
		  @Ld_Status_DATE							DATE,
		  @Ld_SourceReceived_DATE					DATE,
		  @Ld_BeginEmployment_DATE					DATE;
		  
 BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @An_MemberMci_IDNO = CAST(@Ac_Reference_ID AS NUMERIC(10));
   	
   SELECT @An_TransactionEventSeq_NUMB	= e.TransactionEventSeq_NUMB,
		  @Ld_BeginEmployment_DATE		= e.BeginEmployment_DATE,
		  @Lc_Status_CODE				= e.Status_CODE, 	 
		  @Ld_SourceReceived_DATE		= e.SourceReceived_DATE,
		  @Ld_Status_DATE               = e.Status_DATE,
		  @Lc_TypeIncome_CODE           = e.TypeIncome_CODE,
		  @Lc_SourceLocConf_CODE        = e.SourceLocConf_CODE,
		  @Ld_EndEmployment_DATE        = e.EndEmployment_DATE,
		  @Ln_IncomeGross_AMNT          = e.IncomeGross_AMNT,
		  @Ln_IncomeNet_AMNT            = e.IncomeNet_AMNT,
		  @Lc_FreqIncome_CODE           = e.FreqIncome_CODE,
		  @Lc_FreqPay_CODE              = e.FreqPay_CODE,
		  @Lc_EmployerPrime_INDC        = e.EmployerPrime_INDC,
		  @Lc_InsReasonable_INDC        = e.InsReasonable_INDC,
		  @Lc_SourceLoc_CODE            = e.SourceLoc_CODE,
		  @Lc_InsProvider_INDC          = e.InsProvider_INDC,
		  @Lc_DpCovered_INDC            = e.DpCovered_INDC,
		  @Lc_DpCoverageAvlb_INDC       = e.DpCoverageAvlb_INDC,
		  @Ld_EligCoverage_DATE         = e.EligCoverage_DATE,
		  @Ln_CostInsurance_AMNT        = e.CostInsurance_AMNT,
		  @Lc_FreqInsurance_CODE        = e.FreqInsurance_CODE,
		  @Lc_DescriptionOccupation_TEXT	  = e.DescriptionOccupation_TEXT,
		  @Ld_PlsLastSearch_DATE        = e.PlsLastSearch_DATE
     FROM EHIS_Y1 e
    WHERE e.othpPartyEmpl_IDNO = @An_OthpSource_IDNO
	  AND e.MemberMCI_IDNO = @An_MemberMci_IDNO;
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EMPLOYER_UPDATE';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10)) + ', Subsystem_CODE = ' + @Ac_Subsystem_CODE + ', TypeOthpSource_CODE = '+@Ac_TypeOthpSource_CODE+', OthpSource_IDNO = '+CAST(@An_OthpSource_IDNO AS VARCHAR(10))+', ActivityMajor_CODE = '+@Ac_ActivityMajor_CODE+', ActivityMinor_CODE = '+@Ac_ActivityMinor_CODE+', ReasonStatus_CODE = '+@Ac_ReasonStatus_CODE;
   EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
     @An_MemberMci_IDNO            = @An_MemberMci_IDNO,
	 @An_OthpPartyEmpl_IDNO        = @An_OthpSource_IDNO,
	 @Ad_SourceReceived_DATE       = @Ld_SourceReceived_DATE,
	 @Ac_Status_CODE               = @Lc_Status_CODE,
	 @Ad_Status_DATE               = @Ld_Status_DATE,
	 @Ac_TypeIncome_CODE           = @Lc_TypeIncome_CODE,
	 @Ac_SourceLocConf_CODE        = @Lc_SourceLocConf_CODE,
	 @Ad_Run_DATE                  = @Ad_Run_DATE,
	 @Ad_BeginEmployment_DATE      = @Ld_BeginEmployment_DATE,
	 @Ad_EndEmployment_DATE        = @Ld_EndEmployment_DATE,
	 @An_IncomeGross_AMNT          = @Ln_IncomeGross_AMNT,
	 @An_IncomeNet_AMNT            = @Ln_IncomeNet_AMNT,
	 @Ac_FreqIncome_CODE           = @Lc_FreqIncome_CODE,
	 @Ac_FreqPay_CODE              = @Lc_FreqPay_CODE,
	 @Ac_LimitCcpa_INDC            = @Lc_LimitCcpaYes_INDC,
	 @Ac_EmployerPrime_INDC        = @Lc_EmployerPrime_INDC,
	 @Ac_InsReasonable_INDC        = @Lc_InsReasonable_INDC,
	 @Ac_SourceLoc_CODE            = @Lc_SourceLoc_CODE,
	 @Ac_InsProvider_INDC          = @Lc_InsProvider_INDC,
	 @Ac_DpCovered_INDC            = @Lc_DpCovered_INDC,
	 @Ac_DpCoverageAvlb_INDC       = @Lc_DpCoverageAvlb_INDC,
	 @Ad_EligCoverage_DATE         = @Ld_EligCoverage_DATE,
	 @An_CostInsurance_AMNT        = @Ln_CostInsurance_AMNT,
	 @Ac_FreqInsurance_CODE        = @Lc_FreqInsurance_CODE,
	 @Ac_DescriptionOccupation_TEXT= @Lc_DescriptionOccupation_TEXT,
	 @Ac_SignedOnWorker_ID         = @Ac_WorkerUpdate_ID,
	 @An_TransactionEventSeq_NUMB  = @An_TransactionEventSeq_NUMB,
	 @Ad_PlsLastSearch_DATE        = @Ld_PlsLastSearch_DATE,
	 @Ac_Process_ID                = @Ac_Process_ID,
	 @An_OfficeSignedOn_IDNO       = NULL,
	 @Ac_Msg_CODE                  = @Ac_Msg_CODE OUTPUT,
	 @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT OUTPUT;
	 
	 IF (@Ac_Msg_CODE != @Lc_StatusSuccess_CODE)
		 BEGIN
			IF (LEN(@Ac_Msg_CODE) != 5)
			BEGIN
				RAISERROR(50001,16,1);
			END;
			RETURN; 
		 END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
		 SET @Li_Error_NUMB = ERROR_NUMBER ();
		 SET @Li_ErrorLine_NUMB = ERROR_LINE ();

         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END
         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Routine_TEXT,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
