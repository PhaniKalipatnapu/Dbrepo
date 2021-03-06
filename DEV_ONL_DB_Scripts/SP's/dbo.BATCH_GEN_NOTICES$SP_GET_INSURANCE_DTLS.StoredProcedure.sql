/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_INSURANCE_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_INSURANCE_DTLS](
 @An_Case_IDNO             NUMERIC(6),
 @Ad_Run_DATE              DATE,
 @Ac_Reference_ID		   CHAR(30),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE			CHAR(1) = 'S',
		  @Lc_StatusFailed_CODE				CHAR(1) = 'F',
		  @Lc_NcpIns_INDC					CHAR(1) = 'A',
		  @Lc_CpIns_INDC					CHAR(1) = 'C',
		  @Lc_BothIns_INDC					CHAR(1) = 'B',
		  @Lc_CheckBox_Value				CHAR(1) = 'X',
		  @Lc_InsOrdered_CODE				CHAR(1) = 'N',
		  --13707 - SORD - SORD Wrong Insurance Orders -START-
		  @Lc_StatusCaseOpen_CODE			CHAR(1) = 'O',
		  @Lc_CaseRelationship_CODE			CHAR(1) = '',
		  @Lc_Empty_TEXT					CHAR(1) = '',	
		  @Lc_CaseMemberStatusAcitve_CODE   CHAR(1) = 'A',
		  --13707 - SORD - SORD Wrong Insurance Orders -END-
          @Ls_Procedure_NAME				VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_INSURANCE_DTLS',
          @Ld_High_DATE						DATE = '12/31/9999';
  DECLARE @Ln_Reference_ID					NUMERIC(10), 
          @Ln_Error_NUMB					NUMERIC(11),
          @Ln_ErrorLine_NUMB				NUMERIC(11),
          @Ls_Sql_TEXT						VARCHAR(200),
          @Ls_Sqldata_TEXT					VARCHAR(400),
          @Ls_DescriptionError_TEXT			VARCHAR(4000) = '';

  BEGIN TRY
	 SET @Ac_Msg_CODE = NULL;
	 SET @As_DescriptionError_TEXT = NULL;
	 
	 --13707 - SORD - SORD Wrong Insurance Orders -START-
	 SET @Ls_Sql_TEXT = ' Select CaseRelationship_CODE ';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + 'Reference_ID=' + ISNULL(CAST(@Ac_Reference_ID AS VARCHAR), '') ;
     
	 SELECT @Lc_CaseRelationship_CODE = CaseRelationship_CODE 
	   FROM CMEM_Y1 a, CASE_Y1 b
	  WHERE a.Case_IDNO = b.Case_IDNO
	    AND a.MemberMci_IDNO = LTRIM(RTRIM(@Ac_Reference_ID))
	    AND b.Case_IDNO = @An_Case_IDNO
	    AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusAcitve_CODE
	    AND b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
	 --13707 - SORD - SORD Wrong Insurance Orders -END-
	 
     SET @Ls_Sql_TEXT = ' INSERT #NoticeElementsData_P1 ';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + 'InsOrdered_CODE=' + ISNULL(CAST(@Lc_InsOrdered_CODE AS VARCHAR), '') ;
	
	 --13707 - SORD - SORD Wrong Insurance Orders -START-
	 IF @Lc_CaseRelationship_CODE = 'A' 
	  BEGIN
       INSERT INTO #NoticeElementsData_P1
                   (Element_Name,
                    Element_Value)
       (SELECT Element_Name,
               Element_Value
          FROM (SELECT CONVERT(VARCHAR(100), MED_INS_INDC) MED_INS_CODE,
                       CONVERT(VARCHAR(100), DEN_INS_INDC) DEN_INS_CODE,
                       CONVERT(VARCHAR(100), VIS_INS_INDC) VIS_INS_CODE,
                       CONVERT(VARCHAR(100), PREC_INS_INDC) PREC_INS_CODE,
                       CONVERT(VARCHAR(100), CHK_MEN_INS) MEN_INS_CODE,
                       CONVERT(VARCHAR(100), OTHER_INS_INDC) OTHER_INS_CODE,
                       CONVERT(VARCHAR(100), ALL_INS_INDC) ALL_INS_CODE,
                       CONVERT(VARCHAR(100), DescriptionCoverageOthers_TEXT) OTHER_INS_TEXT
                  FROM (SELECT MAX(CASE
                                    WHEN s.CoverageMedical_CODE IN( @Lc_NcpIns_INDC,@Lc_BothIns_INDC)
                                     THEN @Lc_CheckBox_Value
                                    ELSE @Lc_Empty_TEXT
                                   END)MED_INS_INDC,
                               MAX(CASE
                                    WHEN s.CoverageDental_CODE IN( @Lc_NcpIns_INDC,@Lc_BothIns_INDC)
                                     THEN @Lc_CheckBox_Value
                                    ELSE @Lc_Empty_TEXT
                                   END)DEN_INS_INDC,
                               MAX(CASE
                                    WHEN s.CoverageVision_CODE IN( @Lc_NcpIns_INDC,@Lc_BothIns_INDC)
                                     THEN @Lc_CheckBox_Value
                                    ELSE @Lc_Empty_TEXT
                                   END)VIS_INS_INDC,
                               MAX(CASE
                                    WHEN s.CoverageDrug_CODE IN( @Lc_NcpIns_INDC,@Lc_BothIns_INDC)
                                     THEN @Lc_CheckBox_Value
                                    ELSE @Lc_Empty_TEXT
                                   END)PREC_INS_INDC,
                               MAX(CASE
                                    WHEN s.CoverageMental_CODE IN( @Lc_NcpIns_INDC,@Lc_BothIns_INDC)
                                     THEN @Lc_CheckBox_Value
                                    ELSE @Lc_Empty_TEXT
                                   END)CHK_MEN_INS,
                               MAX(CASE
                                    WHEN s.CoverageOthers_CODE IN( @Lc_NcpIns_INDC,@Lc_BothIns_INDC)
                                     THEN @Lc_CheckBox_Value
                                    ELSE @Lc_Empty_TEXT
                                   END)OTHER_INS_INDC,
                               MAX(CASE
                                    WHEN s.CoverageMedical_CODE IN( @Lc_NcpIns_INDC,@Lc_BothIns_INDC)
                                         AND s.CoverageDental_CODE IN( @Lc_NcpIns_INDC,@Lc_BothIns_INDC)
                                         AND s.CoverageVision_CODE IN( @Lc_NcpIns_INDC,@Lc_BothIns_INDC)
                                         AND s.CoverageDrug_CODE IN( @Lc_NcpIns_INDC,@Lc_BothIns_INDC)
                                         AND s.CoverageMental_CODE IN( @Lc_NcpIns_INDC,@Lc_BothIns_INDC)
                                     THEN @Lc_CheckBox_Value
                                    ELSE @Lc_Empty_TEXT
                                   END) ALL_INS_INDC,
                               s.DescriptionCoverageOthers_TEXT
                         FROM SORD_Y1 s
                        WHERE s.InsOrdered_CODE <> @Lc_InsOrdered_CODE
                          AND s.Case_IDNO = @An_Case_IDNO
                          AND s.EndValidity_DATE = @Ld_High_DATE
					      AND @Ad_Run_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
                        GROUP BY s.DescriptionCoverageOthers_TEXT) a) up UNPIVOT (Element_Value FOR Element_Name IN ( MED_INS_CODE, DEN_INS_CODE, VIS_INS_CODE, PREC_INS_CODE, MEN_INS_CODE, OTHER_INS_CODE, ALL_INS_CODE, OTHER_INS_TEXT )) AS pvt);
	  END
	 ELSE
	  BEGIN
	   INSERT INTO #NoticeElementsData_P1
                    (Element_Name,
                     Element_Value)
        (SELECT Element_Name,
                Element_Value
           FROM (SELECT CONVERT(VARCHAR(100), MED_INS_INDC) MED_INS_CODE,
                        CONVERT(VARCHAR(100), DEN_INS_INDC) DEN_INS_CODE,
                        CONVERT(VARCHAR(100), VIS_INS_INDC) VIS_INS_CODE,
                        CONVERT(VARCHAR(100), PREC_INS_INDC) PREC_INS_CODE,
                        CONVERT(VARCHAR(100), CHK_MEN_INS) MEN_INS_CODE,
                        CONVERT(VARCHAR(100), OTHER_INS_INDC) OTHER_INS_CODE,
                        CONVERT(VARCHAR(100), ALL_INS_INDC) ALL_INS_CODE,
                        CONVERT(VARCHAR(100), DescriptionCoverageOthers_TEXT) OTHER_INS_TEXT
                  FROM (SELECT MAX(CASE
                                    WHEN s.CoverageMedical_CODE IN( @Lc_CpIns_INDC,@Lc_BothIns_INDC)
                                     THEN @Lc_CheckBox_Value
                                    ELSE @Lc_Empty_TEXT
                                   END)MED_INS_INDC,
                               MAX(CASE
                                    WHEN s.CoverageDental_CODE IN( @Lc_CpIns_INDC,@Lc_BothIns_INDC)
                                     THEN @Lc_CheckBox_Value
                                    ELSE @Lc_Empty_TEXT
                                   END)DEN_INS_INDC,
                               MAX(CASE
                                    WHEN s.CoverageVision_CODE IN( @Lc_CpIns_INDC,@Lc_BothIns_INDC)
                                     THEN @Lc_CheckBox_Value
                                    ELSE @Lc_Empty_TEXT
                                   END)VIS_INS_INDC,
                               MAX(CASE
                                    WHEN s.CoverageDrug_CODE IN( @Lc_CpIns_INDC,@Lc_BothIns_INDC)
                                     THEN @Lc_CheckBox_Value
                                    ELSE @Lc_Empty_TEXT
                                   END)PREC_INS_INDC,
                               MAX(CASE
                                    WHEN s.CoverageMental_CODE IN( @Lc_CpIns_INDC,@Lc_BothIns_INDC)
                                     THEN @Lc_CheckBox_Value
                                    ELSE @Lc_Empty_TEXT
                                   END)CHK_MEN_INS,
                               MAX(CASE
                                    WHEN s.CoverageOthers_CODE IN( @Lc_CpIns_INDC,@Lc_BothIns_INDC)
                                     THEN @Lc_CheckBox_Value
                                    ELSE @Lc_Empty_TEXT
                                   END)OTHER_INS_INDC,
                               MAX(CASE
                                    WHEN s.CoverageMedical_CODE IN( @Lc_CpIns_INDC,@Lc_BothIns_INDC)
                                         AND s.CoverageDental_CODE IN( @Lc_CpIns_INDC,@Lc_BothIns_INDC)
                                         AND s.CoverageVision_CODE IN( @Lc_CpIns_INDC,@Lc_BothIns_INDC)
                                         AND s.CoverageDrug_CODE IN( @Lc_CpIns_INDC,@Lc_BothIns_INDC)
                                         AND s.CoverageMental_CODE IN( @Lc_CpIns_INDC,@Lc_BothIns_INDC)
                                     THEN @Lc_CheckBox_Value
                                    ELSE @Lc_Empty_TEXT
                                   END) ALL_INS_INDC,
                               s.DescriptionCoverageOthers_TEXT
                         FROM SORD_Y1 s
                        WHERE s.InsOrdered_CODE <> @Lc_InsOrdered_CODE
                          AND s.Case_IDNO = @An_Case_IDNO
                          AND s.EndValidity_DATE = @Ld_High_DATE
					      AND @Ad_Run_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
                        GROUP BY DescriptionCoverageOthers_TEXT)a) up UNPIVOT (Element_Value FOR Element_Name IN ( MED_INS_CODE, DEN_INS_CODE, VIS_INS_CODE, PREC_INS_CODE, MEN_INS_CODE, OTHER_INS_CODE, ALL_INS_CODE, OTHER_INS_TEXT )) AS pvt);
	END
	--13707 - SORD - SORD Wrong Insurance Orders -END-
	
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
