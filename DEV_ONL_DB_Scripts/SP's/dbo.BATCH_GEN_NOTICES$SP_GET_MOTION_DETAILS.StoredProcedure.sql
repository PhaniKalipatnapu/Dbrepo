/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_MOTION_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_MOTION_DETAILS](
 @An_Case_IDNO             NUMERIC(6),
 @An_MajorIntSeq_NUMB      NUMERIC(5) = 0,
 @Ac_ActivityMajor_CODE    CHAR(4),
 @Ac_ActivityMinor_CODE    CHAR(5),
 @Ac_ReasonStatus_CODE     CHAR(2) = ' ',
 @Ac_PrintMethod_CODE      CHAR(1),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE        CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE       CHAR(1) = 'S',
          @Lc_TypeAddress_CODE         CHAR(1) = 'C',
          @Lc_MailingTypeAddress_CODE  CHAR(1) = 'M',
          @Lc_Status_CODE              CHAR(1) = 'Y',
          @Lc_CaseRelationshipCP_CODE  CHAR(1) = 'C',
          @Lc_CaseRelationshipNCP_CODE CHAR(1) = 'A',
          @Lc_PrintMethodViewOnly_CODE CHAR(1) = 'V',
          @Lc_ActivityMinorRmdcy_CODE  CHAR(5) = 'RMDCY',
          @Lc_StatusComp_CODE		   CHAR(4) = 'COMP',
          @Lc_StatusStrt_CODE		   CHAR(4) = 'STRT',
          @Ls_Procedure_NAME           VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_MOTION_DETAILS',
          @Ld_High_DATE                DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB			NUMERIC(11),
          @Ln_ErrorLine_NUMB		NUMERIC(11),
          @Ln_Topic_IDNO			NUMERIC(10),
          @Ls_Sql_TEXT				VARCHAR(100),
          @Ls_Sqldata_TEXT			VARCHAR (1000),
          @Ls_DescriptionError_TEXT VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;

   IF @Ac_PrintMethod_CODE != @Lc_PrintMethodViewOnly_CODE
    BEGIN
     SELECT @Ac_ActivityMinor_CODE = ActivityMinorNext_CODE
       FROM ANXT_Y1 a
      WHERE a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
        AND a.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
        AND a.Reason_CODE = @Ac_ReasonStatus_CODE
        AND a.EndValidity_DATE = @Ld_High_DATE;
    END

   SET @Ls_Sql_TEXT = 'INSERT #NoticeElementsData_P1';
   SET @Ls_Sqldata_TEXT = 'CASE_IDNO =	' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@An_MajorIntSeq_NUMB AS VARCHAR), '');

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT Element_NAME,
           Element_VALUE
      FROM (SELECT CONVERT(VARCHAR(200), k.motion_type_text) AS motion_type_text,
                   CONVERT(VARCHAR(200), k.petitioner_ivd_client_indc) AS petitioner_ivd_client_indc,
                   CONVERT(VARCHAR(200), k.all_motions_indc) AS all_motions_indc,
                   CONVERT(VARCHAR(200), k.verified_addr_indc) AS verified_addr_indc,
                   CONVERT(VARCHAR(200), k.mapp_docs_selected_indc) AS mapp_docs_selected_indc,
                   CONVERT(VARCHAR(200), k.motion_account_indc) AS motion_account_indc,
                   CONVERT(VARCHAR(200), k.dep_motion_indc) AS dep_motion_indc,
                   CONVERT(VARCHAR(200), k.payee_change_no_indc) AS payee_change_no_indc,
                   CONVERT(VARCHAR(200), k.payee_change_yes_indc) AS payee_change_yes_indc,
                   CONVERT(VARCHAR(200), k.children_emancipated_no_indc) AS children_emancipated_no_indc,
                   CONVERT(VARCHAR(200), k.children_emancipated_yes_indc) AS children_emancipated_yes_indc,
                   CONVERT(VARCHAR(200), k.revoke_arrs_pymt_no_indc) AS revoke_arrs_pymt_no_indc,
                   CONVERT(VARCHAR(200), k.revoke_arrs_pymt_yes_indc) AS revoke_arrs_pymt_yes_indc,
                   CONVERT(VARCHAR(200), k.tanf_arrs_cost_eff_no_indc) AS tang_arrs_cost_eff_no_indc,
                   CONVERT(VARCHAR(200), k.tanf_arrs_cost_eff_yes_indc) AS tang_arrs_cost_eff_yes_indc,
                   CONVERT(VARCHAR(200), k.ArrearsTypeAndAmount_TEXT) AS arrears_type
              FROM (SELECT ISNULL((SELECT r.DescriptionValue_TEXT
                                     FROM REFM_Y1 r
                                    WHERE r.TABLE_ID = 'CPRO'
                                      AND r.TABLESUB_ID = 'REAS'
                                      AND r.Value_CODE = s.ReasonStatus_CODE), ' ') AS motion_type_text,
                           CASE
                            WHEN s.TypeCase_CODE != 'H'
                             THEN 'X'
                            ELSE ''
                           END petitioner_ivd_client_indc,
                           all_motions_indc,
                           CASE
                            WHEN (s.CpMailAddrVer_Count > 0
                                  AND s.NcpMailAddrVer_Count > 0
                                  AND NcpLKCAddrVer_Count > 0)
                             THEN 'X'
                            ELSE ''
                           END AS verified_addr_indc,
                           'X' AS mapp_docs_selected_indc,
                           s.motion_account_indc,
                           s.dep_motion_indc,
                           s.payee_change_no_indc,
                           s.payee_change_yes_indc,
                           s.children_emancipated_no_indc,
                           s.children_emancipated_yes_indc,
                           s.revoke_arrs_pymt_no_indc,
                           s.revoke_arrs_pymt_yes_indc,
                           s.tanf_arrs_cost_eff_no_indc,
                           s.tanf_arrs_cost_eff_yes_indc,
                           s.ArrearsTypeAndAmount_TEXT
                      FROM (SELECT @Ac_ReasonStatus_CODE AS ReasonStatus_CODE,
                                   b.TypeCase_CODE,
                                   'X' AS all_motions_indc,
                                   ISNULL((SELECT TOP 1 COUNT(1)
                                             FROM AHIS_Y1 e,
                                                  CMEM_Y1 f
                                            WHERE f.Case_IDNO = @An_Case_IDNO
                                              AND e.MemberMci_IDNO = f.MemberMci_IDNO
                                              AND f.CaseRelationship_CODE IN (@Lc_CaseRelationshipCP_CODE)
                                              AND (Status_CODE = @Lc_Status_CODE
                                                   AND TypeAddress_CODE = @Lc_MailingTypeAddress_CODE)
                                              AND @Ad_Run_DATE BETWEEN e.Begin_DATE AND e.End_DATE), 0) AS CpMailAddrVer_Count,
                                   ISNULL((SELECT TOP 1 COUNT(1)
                                             FROM AHIS_Y1 e,
                                                  CMEM_Y1 f
                                            WHERE f.Case_IDNO = @An_Case_IDNO
                                              AND e.MemberMci_IDNO = f.MemberMci_IDNO
                                              AND f.CaseRelationship_CODE IN (@Lc_CaseRelationshipNCP_CODE)
                                              AND (Status_CODE = @Lc_Status_CODE
                                                   AND TypeAddress_CODE = @Lc_MailingTypeAddress_CODE)
                                              AND @Ad_Run_DATE BETWEEN e.Begin_DATE AND e.End_DATE), 0) AS NcpMailAddrVer_Count,
                                   ISNULL((SELECT TOP 1 COUNT(1)
                                             FROM AHIS_Y1 e,
                                                  CMEM_Y1 f
                                            WHERE f.Case_IDNO = @An_Case_IDNO
                                              AND e.MemberMci_IDNO = f.MemberMci_IDNO
                                              AND f.CaseRelationship_CODE IN (@Lc_CaseRelationshipNCP_CODE)
                                              AND (Status_CODE = @Lc_Status_CODE
                                                   AND TypeAddress_CODE = @Lc_TypeAddress_CODE)
                                              AND @Ad_Run_DATE BETWEEN e.Begin_DATE AND e.End_DATE), 0) AS NcpLKCAddrVer_Count,
                                   a.Topic_IDNO,
                                   'X' motion_account_indc,
                                   'X' dep_motion_indc,
                                   ' ' payee_change_yes_indc,
                                   'X' payee_change_no_indc,
                                   (CASE
                                     WHEN @Ac_ReasonStatus_CODE = 'MC'
                                      THEN 'X'
                                     ELSE ''
                                    END) AS children_emancipated_yes_indc,
                                   (CASE
                                     WHEN @Ac_ReasonStatus_CODE != 'MC'
                                      THEN 'X'
                                     ELSE ''
                                    END) AS children_emancipated_No_indc,
                                   (CASE
                                     WHEN @Ac_ReasonStatus_CODE = 'MA'
                                      THEN 'X'
                                     ELSE ''
                                    END) AS revoke_arrs_pymt_yes_indc,
                                   (CASE
                                     WHEN @Ac_ReasonStatus_CODE != 'MA'
                                      THEN 'X'
                                     ELSE ''
                                    END) AS revoke_arrs_pymt_No_indc,
                                   (CASE
                                     WHEN c.Paa_Arrears <= 500
                                      THEN 'X'
                                     ELSE ''
                                    END) AS tanf_arrs_cost_eff_yes_indc,
                                   (CASE
                                     WHEN (c.Paa_Arrears > 500 OR ISNULL(c.Paa_Arrears,0)= 0)
                                      THEN 'X'
                                     ELSE ''
                                    END) AS tanf_arrs_cost_eff_No_indc,
                                   'TANF Arrears: $' + CAST(Paa_Arrears AS VARCHAR) + ',	and Non-TANF Arrears: $' + CAST(Naa_Arrears AS VARCHAR) AS ArrearsTypeAndAmount_TEXT
                              FROM DMNR_Y1 a,
                                   CASE_Y1 b
									LEFT OUTER JOIN
									   (SELECT a.Case_IDNO,
											   SUM((a.OweTotpaa_AMNT - a.AppTotpaa_AMNT) + (a.OweTottaa_AMNT - a.AppTottaa_AMNT) + (a.OweTotcaa_AMNT - a.AppTotcaa_AMNT)) Paa_Arrears,
											   SUM((a.OweTotnaa_AMNT - a.AppTotnaa_AMNT) + (a.OweTotupa_AMNT - a.AppTotupa_AMNT) + (a.OweTotuda_AMNT - a.AppTotuda_AMNT)) Naa_Arrears
										  FROM LSUP_Y1 a
										 WHERE Case_IDNO = @An_Case_IDNO
										   AND SupportYearMonth_NUMB = (SELECT MAX(SupportYearMonth_NUMB)
																		  FROM LSUP_Y1 b
																		 WHERE b.Case_IDNO = a.Case_IDNO
																		   AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
																		   AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB)
										   AND EventGlobalSeq_NUMB = (SELECT MAX(EventGlobalSeq_NUMB)
																		FROM LSUP_Y1 b
																	   WHERE b.Case_IDNO = a.Case_IDNO
																		 AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
																		 AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB)
										 GROUP BY a.Case_IDNO) c
									ON b.Case_IDNO = c.Case_IDNO
                             WHERE a.CASE_IDNO = @An_Case_IDNO
                               AND b.CASE_IDNO = a.case_idno
                               AND a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
                               AND a.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
                               AND a.Status_CODE = (SELECT CASE WHEN @Ac_ActivityMinor_CODE = @Lc_ActivityMinorRmdcy_CODE THEN @Lc_StatusComp_CODE ELSE @Lc_StatusStrt_CODE END)
                               AND a.ActivityMinor_CODE = @Ac_ActivityMinor_CODE)S)K) up UNPIVOT (Element_VALUE FOR Element_NAME IN ( motion_type_text, petitioner_ivd_client_indc, all_motions_indc, verified_addr_indc, mapp_docs_selected_indc,  motion_account_indc, dep_motion_indc, payee_change_no_indc, payee_change_yes_indc, children_emancipated_no_indc, children_emancipated_yes_indc, revoke_arrs_pymt_no_indc, revoke_arrs_pymt_yes_indc, tang_arrs_cost_eff_no_indc, tang_arrs_cost_eff_yes_indc, arrears_type)) AS pvt);
   
   SELECT @Ln_Topic_IDNO = a.Topic_IDNO
     FROM DMNR_Y1 a
    WHERE a.CASE_IDNO = @An_Case_IDNO
      AND a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
      AND a.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
      AND a.Status_CODE = (SELECT CASE WHEN @Ac_ActivityMinor_CODE = @Lc_ActivityMinorRmdcy_CODE THEN @Lc_StatusComp_CODE ELSE @Lc_StatusStrt_CODE END)
      AND a.ActivityMinor_CODE = @Ac_ActivityMinor_CODE;
   
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   SELECT 'mapp_scan_order_indc', CASE WHEN COUNT(1) > 0 THEN 'X' ELSE '' END AS mapp_scan_order_indc
	 FROM
		(SELECT Barcode_NUMB, xml_text
		  FROM nxml_y1
		 WHERE barcode_numb IN
					(SELECT Barcode_NUMB FROM FORM_Y1 f  WHERE f.Topic_IDNO = @Ln_Topic_IDNO AND ISNUMERIC(f.NOTICE_ID) != 0)
		UNION
		SELECT Barcode_NUMB, xml_text
		  FROM axml_y1
		 WHERE barcode_numb IN
					(SELECT Barcode_NUMB FROM FORM_Y1 f  WHERE f.Topic_IDNO = @Ln_Topic_IDNO AND ISNUMERIC(f.NOTICE_ID) != 0)) a
	WHERE (		(a.xml_text LIKE '%<type_document_code>OIM</type_document_code>%')
			 OR (a.xml_text LIKE '%<type_document_code>OPM</type_document_code>%')
			 OR (a.xml_text LIKE '%<type_document_code>OCO</type_document_code>%')
			 OR (a.xml_text LIKE '%<type_document_code>ODO</type_document_code>%')
			 OR (a.xml_text LIKE '%<type_document_code>OIS</type_document_code>%')
			 OR (a.xml_text LIKE '%<type_document_code>OPC</type_document_code>%')
			 OR (a.xml_text LIKE '%<type_document_code>OSC</type_document_code>%')
			 OR (a.xml_text LIKE '%<type_document_code>OPA</type_document_code>%')
			 OR (a.xml_text LIKE '%<type_document_code>OPD</type_document_code>%')
			 OR (a.xml_text LIKE '%<type_document_code>OSO</type_document_code>%')
			 OR (a.xml_text LIKE '%<type_document_code>RAO</type_document_code>%')
			 OR (a.xml_text LIKE '%<type_document_code>SAA</type_document_code>%')
		  );

   
   
   SET @Ac_MSG_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
          @Ln_Error_NUMB = ERROR_NUMBER(),
          @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF ERROR_NUMBER () <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END;


GO
