/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_ACTION_CHK_BOX_OPTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_ACTION_CHK_BOX_OPTS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_ACTION_CHK_BOX_OPTS] (
 @Ac_Function_CODE          CHAR(3),
 @Ac_Action_CODE            CHAR(1),
 @Ac_Reason_CODE            CHAR(5),
 @An_Case_IDNO              NUMERIC,
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ac_Msg_CODE               CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT  VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
   DECLARE @Lc_StatusFailed_CODE	 CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE	 CHAR(1) = 'S',
           @Lc_CheckBox_Value		 CHAR(1) = 'X',
           @Lc_ActionR_CODE			 CHAR(1) = 'R',
           @Lc_DirectionIncome_CODE	 CHAR(1) = 'I',
           @Lc_FunctionMsc_CODE		 CHAR(3) = 'MSC',
           @Lc_ReasonGrpoc_CODE		 CHAR(5) = 'GRPOC',
           @Lc_ReasonGrgap_CODE		 CHAR(5) = 'GRGAP',
           @Lc_ReasonGragt_CODE		 CHAR(5) = 'GRAGT',
           @Lc_ReasonGrbtr_CODE		 CHAR(5) = 'GRBTR',
           @Lc_ReasonGrafi_CODE		 CHAR(5) = 'GRAFI',
           @Lc_ReasonGrthd_CODE		 CHAR(5) = 'GRTHD',
           @Lc_ReasonGrfin_CODE		 CHAR(5) = 'GRFIN',
           @Ls_Request_IDNO			 VARCHAR(13) = 'Request_IDNO',
           @Ls_Transaction_DATE		 VARCHAR(17) = 'Transaction_DATE',
           @Ls_TransHeader_IDNO		 VARCHAR(17) = 'TransHeader_IDNO',
           @Ls_TransOtherState_INDC	 VARCHAR(21) = 'TransOtherState_INDC',
           @Ls_Procedure_NAME		 VARCHAR(60) = 'BATCH_GEN_NOTICES$SP_ACTION_CHK_BOX_OPTS';
   DECLARE @Lc_check_box1_CODE		 CHAR(1) = '',
           @Lc_check_box2_CODE       CHAR(1) = '',
           @Lc_check_box3_CODE       CHAR(1) = '',
           @Lc_check_box4_CODE       CHAR(1) = '',
           @Lc_check_box5_CODE       CHAR(1) = '',
           @Lc_check_box6_CODE       CHAR(1) = '',
           @Lc_check_box7_CODE       CHAR(1) = '',
           @Lc_TransOtherState_INDC  CHAR(1),
           @Ln_TransHeader_IDNO      NUMERIC(12),
           @Lc_opt_text              VARCHAR(400) = '',
           @Ls_Sql_TEXT              VARCHAR(200) = '',
           @Ls_Sqldata_TEXT          VARCHAR(1000) = '',
           @Ls_DescriptionError_TEXT VARCHAR(4000),
           @Ld_Transaction_DATE      DATE,
           @Ld_High_DATE             DATE = '12/31/9999';

   SET @Ls_Sql_TEXT = 'Function Action Reason';
   SET @Ls_Sqldata_TEXT = 'Function = ' + ISNULL(@Ac_Function_CODE, '') + ', Action = ' + ISNULL(@Ac_Action_CODE, '') + ', Reason = ' + ISNULL(@Ac_Reason_CODE, '');
   
   -- 12904 - CR0309 INT-03 Printed from Received Assist and Discover CSENet Transaction 20131106 Fix - Start

	SELECT @Lc_TransOtherState_INDC = Element_VALUE 
		FROM #NoticeElementsData_P1 
		WHERE Element_NAME = @Ls_TransOtherState_INDC
		
	SELECT @Ld_Transaction_DATE = Element_VALUE 
		FROM #NoticeElementsData_P1 
		WHERE Element_NAME = @Ls_Transaction_DATE
		
	SELECT @Ln_TransHeader_IDNO = Element_VALUE 
		FROM #NoticeElementsData_P1 
		WHERE Element_NAME = @Ls_TransHeader_IDNO 

   -- 12904 - CR0309 INT-03 Printed from Received Assist and Discover CSENet Transaction 20131106 Fix - End
	
   IF (@Ac_Function_CODE = @Lc_FunctionMsc_CODE
       AND @Ac_Action_CODE = @Lc_ActionR_CODE
       AND @Ac_Reason_CODE = @Lc_ReasonGrpoc_CODE)
    BEGIN
     SET @Lc_check_box1_CODE = @Lc_CheckBox_Value; --chk_provide_doc_opt
     SET @Lc_check_box7_CODE =@Lc_CheckBox_Value; --chk_other_forms_opt_code
	 
	 -- 12904 - CR0309 INT-03 Printed from Received Assist and Discover CSENet Transaction 20131106 Fix - Start
		IF @Lc_TransOtherState_INDC = @Lc_DirectionIncome_CODE
			BEGIN
			 SELECT @Lc_opt_text = LTRIM(RTRIM(CF.InfoLine1_TEXT)) + LTRIM(RTRIM(CF.InfoLine2_TEXT)) + LTRIM(RTRIM(CF.InfoLine3_TEXT)) + LTRIM(RTRIM(CF.InfoLine4_TEXT)) + LTRIM(RTRIM(CF.InfoLine5_TEXT))
				FROM CFOB_Y1 CF  -- chk_other_forms_opt_text
				 LEFT OUTER JOIN CTHB_Y1 CT  
				  ON (CF.TransHeader_IDNO = CT.TransHeader_IDNO  
					  AND CF.Transaction_DATE = CT.Transaction_DATE  
					  AND CF.IVDOutOfStateFips_CODE = CT.IVDOutOfStateFips_CODE)  
				WHERE CF.TransHeader_IDNO = @Ln_TransHeader_IDNO  
				 AND CF.Transaction_DATE = @Ld_Transaction_DATE  
				AND CF.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE;  
			END
	 -- 12904 - CR0309 INT-03 Printed from Received Assist and Discover CSENet Transaction 20131106 Fix - End
		ELSE
			BEGIN
			 SELECT TOP 1 @Lc_opt_text = LTRIM(RTRIM(DescriptionComments_TEXT))
			   FROM CSPR_Y1 -- chk_other_forms_opt_text 
			  WHERE Function_CODE = @Ac_Function_CODE
				AND Action_CODE = @Ac_Action_CODE
				AND Reason_CODE = @Ac_Reason_CODE
				AND Case_IDNO = @An_Case_IDNO
				AND IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
				--13856 - Transmittal 3 - ISND Comments for current generation of the document are not being retained. -Fix - Start
				AND Request_IDNO IN(SELECT Element_VALUE
	                                 FROM #NoticeElementsData_P1
	                                WHERE Element_NAME = @Ls_Request_IDNO)
				--13856 - Transmittal 3 - ISND Comments for current generation of the document are not being retained. -Fix - End	                                
				AND EndValidity_DATE = @Ld_High_DATE;
			END
    END

   IF (@Ac_Function_CODE = @Lc_FunctionMsc_CODE
       AND @Ac_Action_CODE = @Lc_ActionR_CODE
       AND @Ac_Reason_CODE = @Lc_ReasonGrgap_CODE)
    BEGIN
     SET @Lc_check_box2_CODE = @Lc_CheckBox_Value; --chk_service_process_opt
    END

   IF (@Ac_Function_CODE = @Lc_FunctionMsc_CODE
       AND @Ac_Action_CODE = @Lc_ActionR_CODE
       AND @Ac_Reason_CODE IN (@Lc_ReasonGragt_CODE, @Lc_ReasonGrbtr_CODE))
    BEGIN
     SET @Lc_check_box3_CODE = @Lc_CheckBox_Value; --chk_genetic_test_opt
    END

   IF (@Ac_Function_CODE = @Lc_FunctionMsc_CODE
       AND @Ac_Action_CODE = @Lc_ActionR_CODE
       AND @Ac_Reason_CODE = @Lc_ReasonGrafi_CODE)
    BEGIN
     SET @Lc_check_box4_CODE = @Lc_CheckBox_Value; --chk_interrogatories_opt
    END

   IF (@Ac_Function_CODE = @Lc_FunctionMsc_CODE
       AND @Ac_Action_CODE = @Lc_ActionR_CODE
       AND @Ac_Reason_CODE = @Lc_ReasonGrthd_CODE)
    BEGIN
     SET @Lc_check_box5_CODE = @Lc_CheckBox_Value; --chk_teleconference_opt
    END

   IF (@Ac_Function_CODE = @Lc_FunctionMsc_CODE
       AND @Ac_Action_CODE = @Lc_ActionR_CODE
       AND @Ac_Reason_CODE = @Lc_ReasonGrfin_CODE)
    BEGIN
     SET @Lc_check_box6_CODE = @Lc_CheckBox_Value; --chk_financial_proof_opt
    END

   INSERT INTO #NoticeElementsData_P1
               (Element_Name,
                Element_Value)
   (SELECT Element_Name,
           Element_Value
      FROM (SELECT CONVERT(VARCHAR(400), chk_provide_doc_opt_code) chk_provide_doc_opt_code,
                   CONVERT(VARCHAR(400), chk_service_process_opt_code) chk_service_process_opt_code,
                   CONVERT(VARCHAR(400), chk_genetic_test_opt_code) chk_genetic_test_opt_code,
                   CONVERT(VARCHAR(400), chk_interrogatories_opt_code) chk_interrogatories_opt_code,
                   CONVERT(VARCHAR(400), chk_teleconference_opt_code) chk_teleconference_opt_code,
                   CONVERT(VARCHAR(400), chk_financial_proof_opt_code) chk_financial_proof_opt_code,
                   CONVERT(VARCHAR(400), chk_other_forms_opt_code) chk_other_forms_opt_code,
                   CONVERT(VARCHAR(400), chk_other_forms_opt_text) chk_other_forms_opt_text
              FROM (SELECT @Lc_check_box1_CODE AS chk_provide_doc_opt_code,
                           @Lc_check_box2_CODE AS chk_service_process_opt_code,
                           @Lc_check_box3_CODE AS chk_genetic_test_opt_code,
                           @Lc_check_box4_CODE AS chk_interrogatories_opt_code,
                           @Lc_check_box5_CODE AS chk_teleconference_opt_code,
                           @Lc_check_box6_CODE AS chk_financial_proof_opt_code,
                           @Lc_check_box7_CODE AS chk_other_forms_opt_code,
                           @Lc_opt_text AS chk_other_forms_opt_text) h)up UNPIVOT (Element_Value FOR Element_Name IN ( chk_provide_doc_opt_code, chk_service_process_opt_code, chk_genetic_test_opt_code, chk_interrogatories_opt_code, chk_teleconference_opt_code, chk_financial_proof_opt_code, chk_other_forms_opt_code, chk_other_forms_opt_text )) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB     INT,
           @Li_ErrorLine_NUMB INT;

   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
