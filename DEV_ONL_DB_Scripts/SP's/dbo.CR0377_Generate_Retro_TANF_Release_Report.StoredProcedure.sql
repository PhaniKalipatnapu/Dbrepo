/****** Object:  StoredProcedure [dbo].[CR0377_Generate_Retro_TANF_Release_Report]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: CR0377_Generate_Retro_TANF_Release_Report
Programmer Name 	: IMP Team
Description			: The procedure CR0377_Generate_Retro_TANF_Release_Report generates retro tanf release 
					  report for the given input date
Frequency			: 'MONTHLY'
Developed On		: 02/20/2015
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[CR0377_Generate_Retro_TANF_Release_Report] ( 
 @Ad_Input_DATE DATE
 )
AS
 BEGIN
  SET NOCOUNT ON;
  
  DECLARE  @Lc_Space_TEXT              CHAR(1) = ' ',
           @Lc_TypeWelfareA_CODE       CHAR(1) = 'A',
           @Lc_CaseRelationshipC_CODE  CHAR(1) = 'C',
           @Lc_CaseRelationshipA_CODE  CHAR(1) = 'A',
           @Lc_CaseRelationshipP_CODE  CHAR(1) = 'P',
           @Lc_CaseMemberStatusA_CODE  CHAR(1) = 'A',
           @Lc_TypeDisburseCgpaa_CODE  CHAR(5) = 'CGPAA',
           @Lc_TypeDisbursePgpaa_CODE  CHAR(5) = 'PGPAA',
           @Lc_Job_ID                  CHAR(7) = 'DEB6340',
           @Ls_Procedure_NAME          VARCHAR(100) = 'CR0377_Generate_Retro_TANF_Release_Report',
           @Ld_Low_DATE                DATE = '01/01/0001',
           @Ld_High_DATE               DATE = '12/31/9999';
  DECLARE  @Ln_Zero_NUMB              NUMERIC = 0,
           @Ln_RowCount_QNTY          NUMERIC,
           @Ln_ErrorLine_NUMB         NUMERIC(11) = 0,
           @Ln_Error_NUMB             NUMERIC(11),
           @Lc_Empty_TEXT             CHAR = '',
           @Lc_Msg_CODE               CHAR(5),
           @Ls_Sql_TEXT               VARCHAR(200) = '',
           @Ls_SqlData_TEXT           VARCHAR(1000) = '',
           @Ls_ErrorMessage_TEXT      VARCHAR(2000),
           @Ls_DescriptionError_TEXT  VARCHAR(4000) = '',
           @Ld_Run_DATE               DATE,
           @Ld_InputMonthBegin_DATE   DATE,
           @Ld_NextRun_DATE           DATE,
           @Ld_InputMonthEnd_DATE     DATE;

  BEGIN TRY  
	SET @Ls_Sql_TEXT = 'GET RUN DATE FROM GIVEN INPUT DATE';
	SET @Ls_SqlData_TEXT = 'Input_DATE = ' + ISNULL(CAST(@Ad_Input_DATE AS VARCHAR), '');

	SET @Ld_InputMonthBegin_DATE = DATEADD(D, -(DATEPART(D, @Ad_Input_DATE) - 1), @Ad_Input_DATE);
	SET @Ld_NextRun_DATE = DATEADD(M, 1, @Ad_Input_DATE);
	SET @Ld_InputMonthEnd_DATE = DATEADD(D, -(DATEPART(D, @Ld_NextRun_DATE)), @Ld_NextRun_DATE);

	SELECT @Ld_Run_DATE = ISNULL((SELECT TOP 1 A.EffectiveRun_DATE
	FROM BSTL_Y1 A
	WHERE A.Job_ID = @Lc_Job_ID
	AND A.EffectiveRun_DATE BETWEEN @Ld_InputMonthBegin_DATE AND @Ld_InputMonthEnd_DATE
	AND A.Status_CODE = 'S'
	ORDER BY A.EffectiveRun_DATE DESC, A.BatchLogSeq_NUMB DESC), @Ld_Low_DATE)

	IF @Ld_Run_DATE = @Ld_Low_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'No Data available for the given Input Month';

     RAISERROR (50001,16,1);
    END;

    SET @Ls_Sql_TEXT = 'GENERATE RETRO TANF RELEASE REPORT';
    SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

	SELECT  IVD_Case_ID, Child_MCI, NCP_MCI, CP_MCI, CP_Name, IVA_Case_ID,
			 MonthInWhichChildSupportCollectionIsAppliedTowardsRetroGrants,
			 ChildSupport_CollectedMonth, SUM(Total_Amount) AS ChildSupport_CollectedAmount
	FROM 
	(
		SELECT IVD_Case_ID, Child_MCI, NCP_MCI, CP_MCI, 
		ISNULL((SELECT LTRIM(RTRIM(c.First_NAME)) + @Lc_Space_TEXT + LTRIM(RTRIM(c.Middle_NAME)) + @Lc_Space_TEXT + LTRIM(RTRIM(c.Last_NAME)) FROM DEMO_Y1 c WHERE b.CP_MCI = c.MemberMci_IDNO),'')CP_Name,
		IVA_Case_ID, SUBSTRING(CONVERT(VARCHAR(6),@Ld_Run_DATE,112),1,6) AS MonthInWhichChildSupportCollectionIsAppliedTowardsRetroGrants,
		ChildSupport_CollectedMonth, Total_Amount
		FROM
		(
			SELECT Case_IDNO IVD_Case_ID, 
			ISNULL((SELECT DISTINCT MemberMci_IDNO FROM OBLE_Y1 b WHERE a.Case_IDNO = b.Case_IDNO AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB AND EndValidity_DATE = @Ld_High_DATE),@Ln_Zero_NUMB)Child_MCI,
			ISNULL((SELECT DISTINCT MemberMci_IDNO FROM CMEM_Y1 b WHERE a.Case_IDNO = b.Case_IDNO AND CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE) AND CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE),@Ln_Zero_NUMB)NCP_MCI,
			ISNULL((SELECT DISTINCT MemberMci_IDNO FROM CMEM_Y1 b WHERE a.Case_IDNO = b.Case_IDNO AND CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE AND CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE),@Ln_Zero_NUMB)CP_MCI,
			CaseWelfare_IDNO IVA_Case_ID, WelfareYearMonth_NUMB ChildSupport_CollectedMonth, Total_Amount 
			FROM
			(
				SELECT Case_IDNO, ObligationSeq_NUMB,CaseWelfare_IDNO, WelfareYearMonth_NUMB, SUM(Distribute_AMNT)Total_Amount
				FROM LWEL_Y1 WHERE TypeDisburse_CODE IN (@Lc_TypeDisburseCgpaa_CODE, @Lc_TypeDisbursePgpaa_CODE) AND TypeWelfare_CODE = @Lc_TypeWelfareA_CODE
				AND  SUBSTRING(CONVERT(VARCHAR(6),Distribute_DATE,112),1,6) <> WelfareYearMonth_NUMB
				AND Distribute_DATE = @Ld_Run_DATE
				GROUP BY Case_IDNO, ObligationSeq_NUMB,CaseWelfare_IDNO, WelfareYearMonth_NUMB
			) a
		)b	
	)c
	GROUP BY IVD_Case_ID, Child_MCI, NCP_MCI, CP_MCI, CP_Name, IVA_Case_ID,MonthInWhichChildSupportCollectionIsAppliedTowardsRetroGrants
	, ChildSupport_CollectedMonth
	ORDER BY 1,2,3,4,6,7,8,9;

    SET @Ln_RowCount_QNTY = @@ROWCOUNT;

	IF @Ln_RowCount_QNTY = @Ln_Zero_NUMB
	BEGIN
	 SET @Ls_ErrorMessage_TEXT = 'No Data available for the given Input Month';

	 RAISERROR (50001,16,1);
	END;

  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
