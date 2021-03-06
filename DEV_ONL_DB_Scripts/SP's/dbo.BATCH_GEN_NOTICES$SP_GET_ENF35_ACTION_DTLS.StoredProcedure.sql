/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_ENF35_ACTION_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_ENF35_ACTION_DTLS] (
   @An_Case_IDNO                      NUMERIC (6),
   @An_MemberMci_IDNO                 NUMERIC (10),
   @An_MajorIntSeq_NUMB               NUMERIC (5),
   @Ac_ActivityMajor_CODE             CHAR(4),
   @Ac_Msg_CODE                       CHAR (5) OUTPUT,
   @As_DescriptionError_TEXT          VARCHAR (4000) OUTPUT)
AS
   /*
   ------------------------------------------------------------------------------------------------------------------------------
   Procedure Name  : BATCH_GEN_NOTICES$SP_GET_ENF35_ACTION_DTLS
   Programmer Name : IMP Team
   Description     :
   Frequency       :
   Developed On    : 07/15/2013
   Called BY       : None
   Called On       :
   -------------------------------------------------------------------------------------------------------------------------------
   Modified BY     :
   Modified On     :
   Version No      : 1.0
   --------------------------------------------------------------------------------------------------------------------------------
   */

   BEGIN
      SET  NOCOUNT ON;
      DECLARE
         @Lc_Checkbox_TEXT			CHAR(1)   = 'X',
		 @Lc_Empty_TEXT             CHAR (1)  = '',	
         @Lc_StatusFailed_CODE      CHAR (1)  = 'F',
         @Lc_StatusSuccess_CODE     CHAR (1)  = 'S',
         @LcTypeReferenceFTO_CODE   CHAR (3)  = 'FTO',
         @LcTypeReferenceSTO_CODE   CHAR (3)  = 'STO',
         @LcTypeReferenceLTY_CODE   CHAR (3)  = 'LTY',
         @LcTypeReferenceADO_CODE   CHAR (3)  = 'ADO',
         @LcTypeReferencePDC_CODE   CHAR (3)  = 'PDC',
         @Lc_Status_CODE            CHAR (4)  = 'STRT', 
         @Lc_ActivityMajorAREN_CODE CHAR (4)  = 'AREN',
         @Lc_ActivityMajorFIDM_CODE CHAR (4)  = 'FIDM',
         @Lc_ActivityMajorCSLN_CODE CHAR (4)  = 'CSLN',
         @Lc_ActivityMajorLIEN_CODE CHAR (4)  = 'LIEN',
         @Lc_ActivityMajorLSNR_CODE CHAR (4)  = 'LSNR',
         @Lc_ActivityMajorCpls_CODE	CHAR(4)   = 'CPLS',
         @Lc_ActivityMajorCRPT_CODE CHAR (4)  = 'CRPT',
         @Ls_Procedure_NAME			VARCHAR (100) = 'BATCH_GEN_NOTICES$SP_GET_ENF35_ACTION_DTLS',
         @Ls_DescriptionError_TEXT  VARCHAR (4000) = '',
         @Ln_Error_NUMB				NUMERIC (11),
         @Ln_ErrorLine_NUMB			NUMERIC (11),
         @Ls_Sql_TEXT				VARCHAR (200),
         @Ls_Sqldata_TEXT			VARCHAR (400);

      BEGIN TRY
          IF (    @An_MemberMci_IDNO IS NOT NULL
             AND @An_MemberMci_IDNO > 0)
            
            BEGIN
               SET @Ls_Sql_TEXT = 'INSERT #NoticeElements_P1';
               SET @Ls_Sqldata_TEXT =
                      ' Case_IDNO '
                      + ISNULL (CAST (@An_Case_IDNO AS VARCHAR (10)), @Lc_Empty_TEXT)
                      + ', MemberMci_IDNO =	'
                      + ISNULL (CAST (@An_MemberMci_IDNO AS VARCHAR (10)), @Lc_Empty_TEXT)
                      + ', ActivityMajor_CODE = '
                      +  @Ac_ActivityMajor_CODE ;

                                 
						INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_Value)
                         (
                         SELECT 
                         		pvt.Element_NAME, 
                         		pvt.Element_Value
             				FROM(
                     				SELECT 
	                                  CONVERT (VARCHAR (10), a.federal_tax_offset) AS FEDERAL_TAX_OFFSET,
	                                  CONVERT (VARCHAR (10), a.state_tax_offset) AS STATE_TAX_OFFSET, 
	                                  CONVERT (VARCHAR (10), a.lottery_offset) AS LOTTERY_OFFSET, 
	                                  CONVERT (VARCHAR (10), a.consumer_credit_report) AS CONSUMER_CREDIT_REPORT, 
	                                  CONVERT (VARCHAR (10), a.administrative_offset) AS ADMINISTRATIVE_OFFSET, 
	                                  CONVERT (VARCHAR (10), a.passport_denial) AS PASSPORT_DENIAL, 
	                                  CONVERT (VARCHAR (10), a.financial_institute_data) AS FINANCIAL_INSTITUTE_DATA, 
	                                  CONVERT (VARCHAR (10), a.insurance_claim_intercept) AS INSURANCE_CLAIM_INTERCEPT, 
	                                  CONVERT (VARCHAR (10), a.license_suspension) AS LICENSE_SUSPENSION 
                                  		FROM
		                                  (
			                                   SELECT CASE 
			                            		WHEN (@Ac_ActivityMajor_CODE = @Lc_ActivityMajorAREN_CODE AND d.TypeReference_CODE =@LcTypeReferenceFTO_CODE)
			                            		THEN @Lc_Checkbox_TEXT
			                            		ELSE
			                            		@Lc_Empty_TEXT
			                            		END federal_tax_offset,
			                            		
			                            		CASE 
			                            		WHEN (@Ac_ActivityMajor_CODE = @Lc_ActivityMajorAREN_CODE AND d.TypeReference_CODE =@LcTypeReferenceSTO_CODE)
			                            		THEN @Lc_Checkbox_TEXT
			                            		ELSE
			                            		@Lc_Empty_TEXT
			                            		END state_tax_offset,
			                            		
			                            		CASE 
			                            		WHEN (@Ac_ActivityMajor_CODE = @Lc_ActivityMajorAREN_CODE AND d.TypeReference_CODE =@LcTypeReferenceLTY_CODE)
			                            		THEN @Lc_Checkbox_TEXT
			                            		ELSE
			                            		@Lc_Empty_TEXT
			                            		END lottery_offset,
			                            		
			                            		CASE 
			                            		WHEN @Ac_ActivityMajor_CODE = @Lc_ActivityMajorCRPT_CODE 
			                            		THEN @Lc_Checkbox_TEXT
			                            		ELSE
			                            		@Lc_Empty_TEXT
			                            		END consumer_credit_report,
			                            		
			                            		CASE 
			                            		WHEN (@Ac_ActivityMajor_CODE = @Lc_ActivityMajorAREN_CODE AND d.TypeReference_CODE =@LcTypeReferenceADO_CODE)
			                            		THEN @Lc_Checkbox_TEXT
			                            		ELSE
			                            		@Lc_Empty_TEXT
			                            		END administrative_offset,
			                            		
			                            		CASE 
			                            		WHEN (@Ac_ActivityMajor_CODE = @Lc_ActivityMajorAREN_CODE AND d.TypeReference_CODE =@LcTypeReferencePDC_CODE)
			                            		THEN @Lc_Checkbox_TEXT
			                            		ELSE
			                            		@Lc_Empty_TEXT
			                            		END passport_denial,
			                            		
			                            		CASE 
			                            		WHEN @Ac_ActivityMajor_CODE = @Lc_ActivityMajorFIDM_CODE
			                            		THEN @Lc_Checkbox_TEXT
			                            		ELSE
			                            		@Lc_Empty_TEXT
			                            		END financial_institute_data ,
			                            		
			                            		CASE 
			                            		WHEN ((@Ac_ActivityMajor_CODE IN(@Lc_ActivityMajorCSLN_CODE,@Lc_ActivityMajorLIEN_CODE)) OR (@Ac_ActivityMajor_CODE = @Lc_ActivityMajorAREN_CODE AND d.TypeReference_CODE='INS')) 
			                            		THEN @Lc_Checkbox_TEXT
			                            		ELSE
			                            		@Lc_Empty_TEXT
			                            		END insurance_claim_intercept ,
			                            		CASE 
			                            		--13787 - ENF-35 problem with checkbox - Fix - START
			                            		WHEN @Ac_ActivityMajor_CODE IN (@Lc_ActivityMajorLSNR_CODE,@Lc_ActivityMajorCpls_CODE)
			                            		THEN @Lc_Checkbox_TEXT
			                            		ELSE
			                            		@Lc_Empty_TEXT
			                            		END license_suspension 
			                            		--13787 - ENF-35 problem with checkbox - Fix - END
			                            		
			                            		FROM DMJR_Y1 d
			                            		WHERE 
			                            		d.Case_IDNO = @An_Case_IDNO   AND 
			                            		d.MemberMci_IDNO =  @An_MemberMci_IDNO  AND
			                            		d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB AND
			                            		d.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
			                            	)a
	                            		)
	                            		 up UNPIVOT (Element_Value FOR
                                     					Element_NAME IN (FEDERAL_TAX_OFFSET, STATE_TAX_OFFSET,LOTTERY_OFFSET,CONSUMER_CREDIT_REPORT,ADMINISTRATIVE_OFFSET,PASSPORT_DENIAL,FINANCIAL_INSTITUTE_DATA,INSURANCE_CLAIM_INTERCEPT,LICENSE_SUSPENSION)) AS pvt);
                            		
            END;
            SET @Ac_MSG_CODE = @Lc_StatusSuccess_CODE;
      END TRY
      BEGIN CATCH
         SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
                @Ln_Error_NUMB = ERROR_NUMBER (),
                @Ln_ErrorLine_NUMB = ERROR_LINE ();

         IF ERROR_NUMBER () <> 50001
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME   = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT         = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT     = @Ls_Sqldata_TEXT,
                                                       @An_Error_NUMB       = @Ln_Error_NUMB,
                                                       @An_ErrorLine_NUMB   = @Ln_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;
         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
      END CATCH
   END;

GO
