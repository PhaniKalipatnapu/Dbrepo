/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_OBL_OBR_INS_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_OBL_OBR_INS_DTLS
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	5/3/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_OBL_OBR_INS_DTLS] (
 @An_Case_IDNO             NUMERIC(6),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_InsuranceOrderedBoth_TEXT   CHAR(1) = 'B',
          @Lc_Yes_TEXT                    CHAR(1) = 'Y',
          @Lc_InsuranceOrderedCpOnly_TEXT CHAR(1) = 'C',
          @Lc_Space_TEXT                  CHAR(1) = ' ',
          @Lc_StatusCaseMemberActive_CODE CHAR(1) = 'A',
          @Lc_CaseRelationshipCp_CODE	  CHAR(1) = 'C',
          @Lc_InsOrdCp_TEXT				  CHAR(1) = 'C',
          @Lc_InsOrdNcp_TEXT			  CHAR(1) = 'A',
          @Lc_CaseRelationshipNcp_CODE	  CHAR(1) = 'A',	
          @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_InsOrdBoth_TEXT             CHAR(1) = 'B',
          @Lc_CoverageMedicalOblrA_TEXT	  CHAR(1) = 'A',
          @Lc_CoverageMedicalOblrB_TEXT	  CHAR(1) = 'B',
          @Lc_CheckBoxX1_TEXT             CHAR(1) = 'X',
          @Lc_TypeOthpI1_CODE             CHAR(1) = 'I',
          @Ls_Procedure_NAME              VARCHAR(100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_OBL_OBR_INS_DTLS ',
          @Ld_High_DATE                   DATE = '12/31/9999';
  DECLARE @Li_Error_NUMB				  NUMERIC(11) ,
          @Li_ErrorLine_NUMB			  NUMERIC(11) ,
		  @Ln_MonPremium_Obligor_AMNT     NUMERIC(11, 2),
		  @Ln_MonPremium_Obligee_AMNT     NUMERIC(11, 2),
          @Lc_CoverageMedicalOblrX1_TEXT  CHAR(1),
          @Lc_CoverageMedicalOblrN1_TEXT  CHAR(1),
          @Lc_CoverageMedicalOblr_TEXT    CHAR(1),
          @Lc_PolicyInsNo_Obligor_TEXT    CHAR(20),
          @Lc_PolicyInsNo_Obligee_TEXT    CHAR(20),
          @Ls_OtherParty_Obligor_NAME     VARCHAR(60),
          @Ls_OtherParty_Obligee_NAME     VARCHAR(60),
          @Ls_Sql_TEXT                    VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(400),
          @Ls_DescriptionError_TEXT		  VARCHAR (4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ls_Sql_TEXT = 'SELECT SORD_Y1:';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6));

   SELECT @Lc_CoverageMedicalOblr_TEXT = CASE a.CoverageMedical_CODE  
                                          WHEN @Lc_InsuranceOrderedBoth_TEXT
                                           THEN @Lc_Yes_TEXT
                                          WHEN @Lc_InsuranceOrderedCpOnly_TEXT
                                           THEN @Lc_Yes_TEXT
                                          ELSE @Lc_Space_TEXT
                                         END
     FROM SORD_Y1 a
    WHERE @Ad_Run_DATE BETWEEN a.OrderEffective_DATE AND a.OrderEnd_DATE
      AND a.EndValidity_DATE = @Ld_High_DATE
      AND a.Case_IDNO = @An_Case_IDNO;

   IF @Lc_CoverageMedicalOblr_TEXT IN (@Lc_CoverageMedicalOblrA_TEXT, @Lc_CoverageMedicalOblrB_TEXT)
    BEGIN
     SET @Lc_CoverageMedicalOblrX1_TEXT = @Lc_CheckBoxX1_TEXT;
     SET @Lc_CoverageMedicalOblrN1_TEXT = @Lc_Space_TEXT;
    END
   ELSE
    BEGIN
     SET @Lc_CoverageMedicalOblrN1_TEXT = @Lc_CheckBoxX1_TEXT;
     SET @Lc_CoverageMedicalOblrX1_TEXT = @Lc_Space_TEXT;
    END

   SET @Ls_Sql_TEXT = 'Insert medical coverage details into #NoticeElementsData_P1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6));

   --13625 - INT-04 - General Testimony issues reported by workers Fix - Start

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT(VARCHAR(100), ncp_CoverageMedicalYes_code) ncp_CoverageMedicalYes_code,
                   CONVERT(VARCHAR(100), ncp_CoverageMedicalNo_code) ncp_CoverageMedicalNo_code
              FROM (SELECT @Lc_CoverageMedicalOblrX1_TEXT AS ncp_CoverageMedicalYes_code,
                           @Lc_CoverageMedicalOblrN1_TEXT AS ncp_CoverageMedicalNo_code) h)up UNPIVOT (tag_value FOR tag_name IN ( ncp_CoverageMedicalYes_code, ncp_CoverageMedicalNo_code )) AS pvt);

   SELECT TOP 1 @Ls_OtherParty_Obligor_NAME = p.OtherParty_NAME,
                @Lc_PolicyInsNo_Obligor_TEXT = i.PolicyInsNo_TEXT,
                @Ln_MonPremium_Obligor_AMNT = i.MonthlyPremium_AMNT
     FROM SORD_Y1 s,
          CMEM_Y1 o,
          MINS_Y1 i,
          OTHP_Y1 p
    WHERE s.Case_IDNO = @An_Case_IDNO
      AND s.CoverageMedical_CODE IN (@Lc_InsOrdBoth_TEXT, @Lc_InsOrdNcp_TEXT)
      AND @Ad_Run_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
      AND s.EndValidity_DATE = @Ld_High_DATE
      AND s.Case_IDNO = o.Case_IDNO
      AND o.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE)
      AND o.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
      AND o.MemberMci_IDNO = i.MemberMci_IDNO
      AND i.EndValidity_DATE = @Ld_High_DATE
      AND @Ad_Run_DATE BETWEEN i.Begin_DATE AND i.End_DATE
      AND i.OthpInsurance_IDNO = p.OtherParty_IDNO
      AND p.TypeOthp_CODE = @Lc_TypeOthpI1_CODE
      AND p.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'Insert Insurance details into #NoticeElementsData_P1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6));

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT(VARCHAR(100), obligor_Insurance_Company_NAME) obligor_Insurance_Company_NAME,
                   CONVERT(VARCHAR(100), obligor_Insurance_policyNumber_TEXT) obligor_Insurance_policyNumber_TEXT,
                   CONVERT(VARCHAR(100), obligor_Insurance_premium_AMNT) obligor_Insurance_premium_AMNT
              FROM (SELECT @Ls_OtherParty_Obligor_NAME AS obligor_Insurance_Company_NAME,
                           @Lc_PolicyInsNo_Obligor_TEXT AS obligor_Insurance_policyNumber_TEXT,
                           @Ln_MonPremium_Obligor_AMNT AS obligor_Insurance_premium_AMNT) h)up UNPIVOT (tag_value FOR tag_name IN ( obligor_Insurance_Company_NAME, obligor_Insurance_policyNumber_TEXT, obligor_Insurance_premium_AMNT )) AS pvt);

   SELECT TOP 1 @Ls_OtherParty_Obligee_NAME = p.OtherParty_NAME,
                @Lc_PolicyInsNo_Obligee_TEXT = i.PolicyInsNo_TEXT,
                @Ln_MonPremium_Obligee_AMNT = i.MonthlyPremium_AMNT
     FROM SORD_Y1 s,
          CMEM_Y1 o,
          MINS_Y1 i,
          OTHP_Y1 p
    WHERE s.Case_IDNO = @An_Case_IDNO
      AND s.CoverageMedical_CODE IN (@Lc_InsOrdBoth_TEXT, @Lc_InsOrdCp_TEXT)
      AND @Ad_Run_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
      AND s.EndValidity_DATE = @Ld_High_DATE
      AND s.Case_IDNO = o.Case_IDNO
      AND o.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE)
      AND o.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
      AND o.MemberMci_IDNO = i.MemberMci_IDNO
      AND i.EndValidity_DATE = @Ld_High_DATE
      AND @Ad_Run_DATE BETWEEN i.Begin_DATE AND i.End_DATE
      AND i.OthpInsurance_IDNO = p.OtherParty_IDNO
      AND p.TypeOthp_CODE = @Lc_TypeOthpI1_CODE
      AND p.EndValidity_DATE = @Ld_High_DATE

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT(VARCHAR(100), obligee_Insurance_Company_NAME) obligee_Insurance_Company_NAME,
                   CONVERT(VARCHAR(100), obligee_Insurance_policyNumber_TEXT) obligee_Insurance_policyNumber_TEXT,
                   CONVERT(VARCHAR(100), obligee_Insurance_premium_AMNT) obligee_Insurance_premium_AMNT
              FROM (SELECT @Ls_OtherParty_Obligee_NAME AS obligee_Insurance_Company_NAME,
                           @Lc_PolicyInsNo_Obligee_TEXT AS obligee_Insurance_policyNumber_TEXT,
                           @Ln_MonPremium_Obligee_AMNT AS obligee_Insurance_premium_AMNT) h)up UNPIVOT (tag_value FOR tag_name IN ( obligee_Insurance_Company_NAME, obligee_Insurance_policyNumber_TEXT, obligee_Insurance_premium_AMNT )) AS pvt);
	--13625 - INT-04 - General Testimony issues reported by workers Fix - End
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
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
  END CATCH;
 END


GO
