/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_REMEDY_DETAILS_NCP]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_REMEDY_DETAILS_NCP
Programmer Name	:	IMP Team.
Description		:	This procedure is used to fetch the remedy level details for CSM-12B
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_REMEDY_DETAILS_NCP]
 @An_Case_IDNO             NUMERIC(6),
 @An_NcpMemberMci_IDNO     NUMERIC(10),
 @An_OrderSeq_NUMB         NUMERIC(5),
 @Ad_Run_DATE              DATETIME2,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Lc_StatusFailed_CODE				CHAR(1)			= 'F',
          @Lc_StatusSuccess_CODE			CHAR(1)			= 'S',
          @Lc_CheckBoxChecked_CODE			CHAR(1)			= 'X',
          @Lc_Blank_TEXT					CHAR(1)			= '',
          @Lc_ReasonStatusPj_CODE			CHAR(2)			= 'PJ',
          @Lc_ReasonStatusPm_CODE			CHAR(2)			= 'PM',
		  @Lc_ReasonStatusPs_CODE			CHAR(2)			= 'PS',
		  @Lc_ReasonStatusPt_CODE			CHAR(2)			= 'PT',
		  @Lc_ActivityMajorEstp_CODE		CHAR(4)			= 'ESTP',
          @Lc_ActivityMajorMapp_CODE		CHAR(4)			= 'MAPP',
          @Lc_ActivityMinorAdagr_CODE		CHAR(5)			= 'ADAGR',
          @Lc_JobElfcProcess_ID				CHAR(10)		= 'DEB0665',
          @Ls_Procedure_NAME				VARCHAR(100)	= 'BATCH_GEN_NOTICES$SP_GET_REMEDY_DETAILS_NCP ',
          @Ld_High_DATE						DATE			= '12/31/9999';                    
  DECLARE @Lc_CheckBoxEstp_CODE				CHAR(1)			= '',
          @Lc_ReasonStatusMappPs_CODE		CHAR(1)			= '',
          @Lc_ReasonStatusMappPmPt_CODE		CHAR(1)			= '',
          @Lc_PetitionCheckBoxStatus_CODE	CHAR(1)			= '',
          @Lc_CheckboxObra_CODE				CHAR(1)			= '',
          @Lc_CheckboxImiw_CODE				CHAR(1)			= '',
          @Lc_CheckboxDriv_CODE				CHAR(1)			= '',
          @Lc_CheckboxFish_CODE				CHAR(1)			= '',
          @Lc_CheckboxProf_CODE				CHAR(1)			= '',
          @Lc_CheckboxBuss_CODE				CHAR(1)			= '',
          @Lc_CheckboxLsnr_CODE				CHAR(1)			= '',
          @Lc_CheckboxReinstateDriv_CODE	CHAR(1)			= '',
          @Lc_CheckboxReinstateBuss_CODE	CHAR(1)			= '',
          @Lc_CheckboxReinstateProf_CODE	CHAR(1)			= '',
          @Lc_CheckboxReinstateFish_CODE	CHAR(1)			= '',
          @Lc_CheckboxReinstateLsnr_CODE	CHAR(1)			= '',
          @Lc_CheckboxSord_CODE				CHAR(1)			= '',
          @Lc_CheckboxCrpt_CODE				CHAR(1)			= '',
          @Lc_OutOfStateCorrespondence_TEXT CHAR(1)			= '',
          @Lc_ReciprocalPetition_TEXT		CHAR(1)			= '',
          @Lc_StatusRequest_TEXT			CHAR(1)			= '',
          @Lc_EnforcementRequest_TEXT		CHAR(1)			= '',
          @Lc_OrderEnd_DATE					CHAR(10),
          @Ls_Sql_TEXT						VARCHAR(100)	= '',
          @Ls_Sqldata_TEXT					VARCHAR(400)	= '',
          @Ls_Err_Description_TEXT			VARCHAR(4000)	= '',
          @Ld_PrevioudRun_DATE				DATE;
          
  BEGIN TRY
   
   SET @Ls_Sql_TEXT = 'SELECT PARM_Y1';
   SELECT @Ld_PrevioudRun_DATE = Run_DATE
     FROM PARM_Y1
    WHERE Job_ID = @Lc_JobElfcProcess_ID;
    
    /* CSM-12B 46a element code */
   SET @Ls_Sql_TEXT = 'SELECT DMNR_Y1 FOR ESTP';
   IF EXISTS (SELECT 1
                FROM DMNR_Y1 n
               WHERE n.Case_IDNO = @An_Case_IDNO
                 AND n.ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
                 AND n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusPj_CODE
                 AND n.Status_DATE >=  @Ld_PrevioudRun_DATE)
    BEGIN
     SET @Lc_CheckBoxEstp_CODE = @Lc_CheckBoxChecked_CODE;
    END
    
    /* CSM-12B 46b element code */
   SET @Ls_Sql_TEXT = 'SELECT DMNR_Y1 FOR MAPP 1';
   IF EXISTS (SELECT 1
                FROM DMNR_Y1 n
               WHERE n.Case_IDNO = @An_Case_IDNO
                 AND n.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                 AND n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusPj_CODE
                 AND n.Status_DATE >=  @Ld_PrevioudRun_DATE
                 AND EXISTS (SELECT 1
							   FROM DMNR_Y1 d
							  WHERE d.Case_IDNO = n.Case_IDNO
							    AND d.MajorIntSeq_NUMB = n.MajorIntSeq_NUMB
							    AND d.ReasonStatus_CODE IN ( @Lc_ReasonStatusPm_CODE )))
    BEGIN
     SET @Lc_ReasonStatusMappPmPt_CODE = @Lc_CheckBoxChecked_CODE;
    END
    
     /* CSM-12B 46c element code */
   SET @Ls_Sql_TEXT = 'SELECT DMNR_Y1 FOR MAPP 2';
   IF EXISTS (SELECT 1
                FROM DMNR_Y1 n
               WHERE n.Case_IDNO = @An_Case_IDNO
                 AND n.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                 AND n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusPj_CODE
                 AND n.Status_DATE >=  @Ld_PrevioudRun_DATE
                 AND EXISTS (SELECT 1
							   FROM DMNR_Y1 d
							  WHERE d.Case_IDNO = n.Case_IDNO
							    AND d.MajorIntSeq_NUMB = n.MajorIntSeq_NUMB
							    AND d.ReasonStatus_CODE IN ( @Lc_ReasonStatusPs_CODE , @Lc_ReasonStatusPt_CODE )))
    BEGIN
     SET @Lc_ReasonStatusMappPs_CODE = @Lc_CheckBoxChecked_CODE;
    END
    
   /* CSM-12B 46 element code */
   IF (@Lc_CheckBoxEstp_CODE = @Lc_CheckBoxChecked_CODE
		OR @Lc_ReasonStatusMappPmPt_CODE = @Lc_CheckBoxChecked_CODE
		OR @Lc_ReasonStatusMappPs_CODE = @Lc_CheckBoxChecked_CODE )
	BEGIN
		SET @Lc_PetitionCheckBoxStatus_CODE = @Lc_CheckBoxChecked_CODE;
	END

   /* CSM-12B 51 element code */
   SET @Lc_OrderEnd_DATE = @Ld_High_DATE;

   SELECT @Lc_OrderEnd_DATE = CONVERT(VARCHAR(10), OrderEnd_DATE, 101)
     FROM SORD_Y1 s
    WHERE case_IDNO = @An_Case_IDNO
          AND BeginValidity_DATE >= @Ld_PrevioudRun_DATE
          AND EndValidity_DATE = @Ld_High_DATE
          AND OrderSeq_NUMB = @An_OrderSeq_NUMB;

   IF @Lc_OrderEnd_DATE !=  @Ld_High_DATE
    BEGIN
     SET @Lc_CheckboxSord_CODE = @Lc_CheckBoxChecked_CODE; --51
    END
   ELSE
    BEGIN
     SET @Lc_OrderEnd_DATE = @Lc_Blank_TEXT;
    END

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT(VARCHAR(100), mapp_opt2_code) mapp_opt2_code,
                   CONVERT(VARCHAR(100), mapp_opt3_code) mapp_opt3_code,
                   CONVERT(VARCHAR(100), mapp_opt4_code) mapp_opt4_code,
                   CONVERT(VARCHAR(100), mapp_opt1_code) mapp_opt1_code,
                   CONVERT(VARCHAR(100), obra_opt5_code) obra_opt5_code,
                   CONVERT(VARCHAR(100), iiwo_opt6_code) iiwo_opt6_code,
                   CONVERT(VARCHAR(100), lsnr_opt8_code) lsnr_opt8_code,
                   CONVERT(VARCHAR(100), lsnr_opt9_code) lsnr_opt9_code,
                   CONVERT(VARCHAR(100), lsnr_opt10_code) lsnr_opt10_code,
                   CONVERT(VARCHAR(100), lsnr_opt11_code) lsnr_opt11_code,
                   CONVERT(VARCHAR(100), lsnr_opt7_code) lsnr_opt7_code,
                   CONVERT(VARCHAR(100), lsnr_opt13_code) lsnr_opt13_code,
                   CONVERT(VARCHAR(100), lsnr_opt14_code) lsnr_opt14_code,
                   CONVERT(VARCHAR(100), lsnr_opt15_code) lsnr_opt15_code,
                   CONVERT(VARCHAR(100), lsnr_opt16_code) lsnr_opt16_code,
                   CONVERT(VARCHAR(100), lsnr_opt12_code) lsnr_opt12_code,
                   CONVERT(VARCHAR(100), sord_opt17_code) sord_opt17_code,
                   CONVERT(VARCHAR(100), OrderEnd_DATE) OrderEnd_DATE,
                   CONVERT(VARCHAR(100), out_of_state_correspondence_code) out_of_state_correspondence_code,
                   CONVERT(VARCHAR(100), reciprocal_petition_code) reciprocal_petition_code,
                   CONVERT(VARCHAR(100), status_request_code) status_request_code,
                   CONVERT(VARCHAR(100), enforcement_request_text) enforcement_request_text,
                   CONVERT(VARCHAR(100), crpt_opt23_code) crpt_opt23_code
              FROM (SELECT @Lc_CheckBoxEstp_CODE AS mapp_opt2_code,
                           @Lc_ReasonStatusMappPmPt_CODE AS mapp_opt3_code,
                           @Lc_ReasonStatusMappPs_CODE AS mapp_opt4_code,
                           @Lc_PetitionCheckBoxStatus_CODE AS mapp_opt1_code,
                           @Lc_CheckboxObra_CODE AS obra_opt5_code,
                           @Lc_CheckboxImiw_CODE AS iiwo_opt6_code,
                           @Lc_CheckboxDriv_CODE AS lsnr_opt8_code,
                           @Lc_CheckboxBuss_CODE AS lsnr_opt9_code,
                           @Lc_CheckboxProf_CODE AS lsnr_opt10_code,
                           @Lc_CheckboxFish_CODE AS lsnr_opt11_code,
                           @Lc_CheckboxLsnr_CODE AS lsnr_opt7_code,
                           @Lc_CheckboxReinstateDriv_CODE AS lsnr_opt13_code,
                           @Lc_CheckboxReinstateBuss_CODE AS lsnr_opt14_code,
                           @Lc_CheckboxReinstateProf_CODE AS lsnr_opt15_code,
                           @Lc_CheckboxReinstateFish_CODE AS lsnr_opt16_code,
                           @Lc_CheckboxReinstateLsnr_CODE AS lsnr_opt12_code,
                           @Lc_CheckboxSord_CODE AS sord_opt17_code,
                           @Lc_OrderEnd_DATE AS OrderEnd_DATE,
                           @Lc_OutOfStateCorrespondence_TEXT AS out_of_state_correspondence_code,
                           @Lc_ReciprocalPetition_TEXT AS reciprocal_petition_code,
                           @Lc_StatusRequest_TEXT AS status_request_code,
                           @Lc_EnforcementRequest_TEXT AS enforcement_request_text,
                           @Lc_CheckboxCrpt_CODE AS crpt_opt23_code) a) up UNPIVOT (tag_value FOR tag_name IN ( mapp_opt2_code, mapp_opt3_code, mapp_opt4_code, mapp_opt1_code, obra_opt5_code, iiwo_opt6_code, lsnr_opt8_code, lsnr_opt9_code, lsnr_opt10_code, lsnr_opt11_code, lsnr_opt7_code, lsnr_opt13_code, lsnr_opt14_code, lsnr_opt15_code, lsnr_opt16_code, lsnr_opt12_code, sord_opt17_code, OrderEnd_DATE, out_of_state_correspondence_code, reciprocal_petition_code, status_request_code, enforcement_request_text, crpt_opt23_code )) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB            INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB        INT = ERROR_LINE ();
   DECLARE @Ls_DescriptionError_TEXT VARCHAR (4000);

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
    @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
   END CATCH
 END


GO
