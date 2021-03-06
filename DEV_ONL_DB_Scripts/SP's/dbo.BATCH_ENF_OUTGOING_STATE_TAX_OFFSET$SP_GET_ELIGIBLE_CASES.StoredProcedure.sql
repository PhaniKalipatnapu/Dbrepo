/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_GET_ELIGIBLE_CASES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_GET_ELIGIBLE_CASES
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_GET_ELIGIBLE_CASES is 
					  to get all eligible cases for State Tax Offset
Frequency		:	'WEEKLY'
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_GET_ELIGIBLE_CASES]
 @Ad_Run_DATE              DATE,
 @An_TaxYear_NUMB          NUMERIC(4),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Ls_Procedure_NAME     VARCHAR(100) = 'SP_GET_ELIGIBLE_CASES',
          @Ld_Run_DATE           DATE = @Ad_Run_DATE,
          @Ld_Low_DATE           DATE = '01/01/0001',
          @Ld_High_DATE          DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Empty_TEXT            CHAR = '',
          @Ls_Sql_TEXT              VARCHAR(100) = '',
          @Ls_ErrorMessage_TEXT     VARCHAR(200),
          @Ls_SqlData_TEXT          VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'INSERT #GetEligibleCases_P1';
   SET @Ls_SqlData_TEXT = '';

   INSERT #GetEligibleCases_P1
          (MemberMci_IDNO,
           Case_IDNO,
           County_CODE,
           Office_CODE,
           TypeCase_CODE,
           StatusCase_CODE,
           RespondInit_CODE,
           CaseRelationship_CODE,
           CaseMemberStatus_CODE,
           Last_NAME,
           First_NAME,
           Middle_NAME,
           MemberSsn_NUMB,
           TaxYear_NUMB,
           Create_DATE)
   SELECT DISTINCT
          A.MemberMci_IDNO,
          A.Case_IDNO,
          C.County_IDNO,
          C.Office_IDNO,
          C.TypeCase_CODE,
          C.StatusCase_CODE,
          C.RespondInit_CODE,
          A.CaseRelationship_CODE,
          A.CaseMemberStatus_CODE,
          B.Last_NAME,
          B.First_NAME,
          B.Middle_NAME,
          ISNULL(CASE
                  WHEN B.MemberSsn_NUMB = 0
                   THEN dbo.BATCH_COMMON$SF_GET_VERIFIED_SSN_ITIN (A.MemberMci_IDNO)
                  ELSE B.MemberSsn_NUMB
                 END, 0) AS MemberSsn_NUMB,
          @An_TaxYear_NUMB AS TaxYear_NUMB,
          @Ld_Run_DATE AS Create_DATE
     FROM CMEM_Y1 A,
          DEMO_Y1 B,
          CASE_Y1 C,
          (SELECT DISTINCT
                  D.MemberMci_IDNO,
                  D.Case_IDNO
             FROM ISTX_Y1 D
            WHERE D.TypeTransaction_CODE IN ('I', 'C', 'D')
              AND D.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                         FROM ISTX_Y1 X
                                        WHERE X.MemberMci_IDNO = D.MemberMci_IDNO
                                          AND X.Case_IDNO = D.Case_IDNO
                                          AND X.TypeArrear_CODE = D.TypeArrear_CODE)) Y
    WHERE Y.MemberMci_IDNO = A.MemberMci_IDNO
      AND Y.Case_IDNO = A.Case_IDNO
      AND A.MemberMci_IDNO = B.MemberMci_IDNO
      AND A.Case_IDNO = C.Case_IDNO
   UNION
   SELECT DISTINCT
          A.MemberMci_IDNO,
          A.Case_IDNO,
          C.County_IDNO,
          C.Office_IDNO,
          C.TypeCase_CODE,
          C.StatusCase_CODE,
          C.RespondInit_CODE,
          A.CaseRelationship_CODE,
          A.CaseMemberStatus_CODE,
          B.Last_NAME,
          B.First_NAME,
          B.Middle_NAME,
          ISNULL(CASE
                  WHEN B.MemberSsn_NUMB = 0
                   THEN dbo.BATCH_COMMON$SF_GET_VERIFIED_SSN_ITIN (A.MemberMci_IDNO)
                  ELSE B.MemberSsn_NUMB
                 END, 0) AS MemberSsn_NUMB,
          @An_TaxYear_NUMB AS TaxYear_NUMB,
          @Ld_Run_DATE AS Create_DATE
     FROM CMEM_Y1 A,
          DEMO_Y1 B,
          CASE_Y1 C
    WHERE A.CaseRelationship_CODE IN ('A', 'P')
      AND A.CaseMemberStatus_CODE = 'A'
      AND A.Case_IDNO = C.Case_IDNO
      AND A.MemberMci_IDNO = B.MemberMci_IDNO
      AND ISNULL(B.MemberSsn_NUMB, 0) > 0
      AND B.Deceased_DATE IN ('1753-01-01', @Ld_High_DATE, @Ld_Low_DATE)
      AND C.TypeCase_CODE <> 'H'
      AND C.StatusCase_CODE = 'O'
      AND EXISTS (SELECT 1
                    FROM AHIS_Y1 X
                   WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                     AND X.TypeAddress_CODE IN ('M', 'R')
                     AND X.Status_CODE = 'Y'
                     AND X.End_DATE = @Ld_High_DATE
                     AND LEN(LTRIM(RTRIM(ISNULL(X.Line1_ADDR, '')))) > 0
                     AND X.Country_ADDR = 'US')
      AND NOT EXISTS (SELECT 1
                        FROM TEXC_Y1 X
                       WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                         AND X.Case_IDNO = A.Case_IDNO
                         AND X.EndValidity_DATE = @Ld_High_DATE
                         AND @Ld_Run_DATE BETWEEN X.Effective_DATE AND X.End_DATE
                         AND X.ExcludeState_CODE = 'Y')
      AND EXISTS (SELECT 1
                    FROM MSSN_Y1 X
                   WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                     AND X.TypePrimary_CODE IN ('P', 'I')
                     AND X.Enumeration_CODE = 'Y'
                     AND X.EndValidity_DATE = @Ld_High_DATE)
      AND EXISTS (SELECT 1
                    FROM SORD_Y1 X
                   WHERE X.Case_IDNO = C.Case_IDNO
                     AND @Ad_Run_DATE BETWEEN X.OrderEffective_DATE AND X.OrderEnd_DATE
                     AND X.EndValidity_DATE = @Ld_High_DATE)
    ORDER BY MemberMci_IDNO,
             Case_IDNO;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Empty_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = ERROR_MESSAGE();
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END;


GO
