/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_PETI_INCOME_EXPENSE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_PETI_INCOME_EXPENSE
Programmer Name	:	IMP Team.
Description		:	Procedure to Get the Petioner Income expense details
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICE_CM$SP_GENERATE_NOTICE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_PETI_INCOME_EXPENSE]
 @An_CpMemberMci_IDNO      NUMERIC(10),
 @An_Case_IDNO             NUMERIC(6),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
 SET NOCOUNT ON;
  
  DECLARE @Li_Error_NUMB                     INT = NULL,
          @Li_ErrorLine_NUMB                 INT = NULL,
          @Lc_StatusSuccess_CODE             CHAR = 'S',
          @Lc_StatusFailed_CODE              CHAR = 'F',
          @Lc_Yes_TEXT                       CHAR(1) = 'Y',
          @Lc_SourceIncExpSi_CODE            CHAR(2) = 'SI',
          @Lc_SourceIncExpPa_CODE            CHAR(2) = 'PA',
          @Lc_SourceIncExpEm_CODE            CHAR(2) = 'EM',
          @Lc_SourceIncExpSe_CODE            CHAR(2) = 'SE',
          @Lc_SourceIncExpCo_CODE            CHAR(2) = 'CO',
          @Lc_SourceIncExpUe_CODE            CHAR(2) = 'UE',
          @Lc_SourceIncExpWc_CODE            CHAR(2) = 'WC',
          @Lc_SourceIncExpSd_CODE            CHAR(2) = 'SD',
          @Lc_SourceIncExpDi_CODE            CHAR(2) = 'DI',
          @Lc_SourceIncExpSs_CODE            CHAR(2) = 'SS',
          @Lc_SourceIncExpDv_CODE            CHAR(2) = 'DV',
          @Lc_SourceIncExpAn_CODE            CHAR(2) = 'AN',
          @Lc_SourceIncExpTi_CODE            CHAR(2) = 'TI',
          @Lc_SourceIncExpPe_CODE            CHAR(2) = 'PE',
          @Lc_SourceIncExpRe_CODE            CHAR(2) = 'RE',
          @Lc_SourceIncExpRr_CODE            CHAR(2) = 'RR',
          @Lc_SourceIncExpAl_CODE            CHAR(2) = 'AL',
          @Ls_Procedure_NAME                 VARCHAR(100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_PETITIONER_INCOME_EXPENSE ',
          @Ld_High_DATE                      DATE = '12-31-9999';
         
DECLARE   @Ln_PaIncomeExpense_AMNT           NUMERIC(9)= 0,
          @Ln_EmSeIncomeExpense_AMNT         NUMERIC(9)= 0,
          @Ln_CoIncomeExpense_AMNT           NUMERIC(9)= 0,
          @Ln_UeIncomeExpense_AMNT           NUMERIC(9)= 0,
          @Ln_WcIncomeExpense_AMNT           NUMERIC(9)= 0,
          @Ln_SdDiIncomeExpense_AMNT         NUMERIC(9)= 0,
          @Ln_SsIncomeExpense_AMNT           NUMERIC(9)= 0,
          @Ln_DvIncomeExpense_AMNT           NUMERIC(9)= 0,
          @Ln_AlIncomeExpense_AMNT           NUMERIC(9)= 0,
          @Ln_AnTiIncomeExpense_AMNT         NUMERIC(9)= 0,
          @Ln_PeReIncomeExpense_AMNT         NUMERIC(9)= 0,
          @Ln_sIIncomeExpense_AMNT           NUMERIC(9)=0,
          
          @Lc_Employed_yes_CODE              CHAR(1)='',
           @Lc_Employed_No_CODE              CHAR(1) ='',
          @Ls_PaDescriptionIncomeSource_CODE VARCHAR(70)='',
          @Ls_EmDescriptionIncomeSource_CODE VARCHAR(70)='',
          @Ls_CoDescriptionIncomeSource_CODE VARCHAR(70)='',
          @Ls_UeDescriptionIncomeSource_CODE VARCHAR(70)='',
          @Ls_WcDescriptionIncomeSource_CODE VARCHAR(70)='',
          @Ls_SdDescriptionIncomeSource_CODE VARCHAR(70)='',
          @Ls_SsDescriptionIncomeSource_CODE VARCHAR(70)='',
          @Ls_DvDescriptionIncomeSource_CODE VARCHAR(70)='',
          @Ls_PeDescriptionIncomeSource_CODE VARCHAR(70)='',
          @Ls_AnDescriptionIncomeSource_CODE VARCHAR(70)='',
          @Ls_AlDescriptionIncomeSource_CODE VARCHAR(70)='',
          @Ls_DescriptionOccupation_TEXT     VARCHAR(100)='';
DECLARE   @Ls_sIDescriptionIncomeSource_CODE VARCHAR(70),
          @Ls_SourceOfIncome_TEXT            VARCHAR(100),
          @Ls_Sql_TEXT                       VARCHAR(200),
          @Ls_Sqldata_TEXT                   VARCHAR(400),
          @Ls_DescriptionError_TEXT          VARCHAR(4000);
DECLARE   @Ls_PetIncomeExpences_CUR         CURSOR,
          @Ln_PetIncomeExpensecur_AMNT             NUMERIC(11, 2),
          @Lc_PetIncomeExpensecur_CODE             CHAR(1),
          @Ls_Desc_PetIncomeExpensecur_CODE            VARCHAR(70);           
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL
   SET @As_DescriptionError_TEXT = NULL
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6))
   SET @Ls_Sql_TEXT = 'SELECT CASE_Y1 CMEM_Y1 INEX_Y1:'

   IF @An_CpMemberMci_IDNO != 0
      AND @An_CpMemberMci_IDNO IS NOT NULL
    BEGIN
     SELECT TOP 1 @Lc_Employed_yes_CODE = CASE
                                           WHEN DescriptionOccupation_TEXT != ''
                                                AND DescriptionOccupation_TEXT IS NOT NULL
                                            THEN 'X'
                                           ELSE ''
                                          END,
                  @Ls_DescriptionOccupation_TEXT = DescriptionOccupation_TEXT
       FROM EHIS_Y1 e
      WHERE e.MemberMci_IDNO = @An_CpMemberMci_IDNO
        AND @Ad_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE
        AND e.Status_CODE = @Lc_Yes_TEXT
        AND e.BeginEmployment_DATE = (SELECT MAX (e.BeginEmployment_DATE)
                                        FROM EHIS_Y1 e
                                       WHERE e.MemberMci_IDNO = @An_CpMemberMci_IDNO
                                         AND @Ad_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE
                                         AND e.Status_CODE = @Lc_Yes_TEXT);
    END

   IF (@Lc_Employed_yes_CODE = 'X')
    BEGIN
     SET @Lc_Employed_No_CODE = ''
     SET @Ls_SourceOfIncome_TEXT = '';
    END
   ELSE
    BEGIN
     SELECT @Ls_SourceOfIncome_TEXT = dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE('INEX', 'EXPT', i.SourceIncome_CODE),
            @Lc_Employed_No_CODE = ''
       FROM INCM_Y1 i
      WHERE i.MemberMci_IDNO = @An_CpMemberMci_IDNO
        AND i.EndValidity_DATE = @Ld_High_DATE
    END

   IF (@Lc_Employed_yes_CODE IS NULL
        OR @Lc_Employed_yes_CODE = ''
        OR @Lc_Employed_No_CODE IS NULL
        OR @Lc_Employed_No_CODE = '')
    BEGIN
     SET @Lc_Employed_No_CODE = ''
     SET @Ls_SourceOfIncome_TEXT = '';
    END

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   SELECT pvt.Element_NAME,
          pvt.Element_VALUE
     FROM (SELECT CAST(Petitioiner_Employed_yes_CODE AS VARCHAR(100)) AS Petitioiner_Employed_yes_CODE,
                  CAST(Petitioiner_Employed_no_CODE AS VARCHAR(100)) AS Petitioiner_Employed_no_CODE,
                  CAST(Petitioner_DescriptionOccupation_TEXT AS VARCHAR(100)) AS Petitioner_DescriptionOccupation_TEXT,
                  CAST(Petitioner_SourceOfIncome_TEXT AS VARCHAR(100)) AS Petitioner_SourceOfIncome_TEXT
             FROM (SELECT @Lc_Employed_yes_CODE AS Petitioiner_Employed_yes_CODE,
                          @Lc_Employed_No_CODE AS Petitioiner_Employed_no_CODE,
                          @Ls_DescriptionOccupation_TEXT AS Petitioner_DescriptionOccupation_TEXT,
                          @Ls_SourceOfIncome_TEXT AS Petitioner_SourceOfIncome_TEXT) a) up UNPIVOT (Element_VALUE FOR Element_NAME IN ( Petitioiner_Employed_yes_CODE, Petitioiner_Employed_no_CODE, Petitioner_DescriptionOccupation_TEXT, Petitioner_SourceOfIncome_TEXT )) AS pvt;

   DECLARE Ls_PetIncomeExpences_Cur CURSOR FOR
    SELECT n.SourceIncome_CODE,
           n.Income_AMNT,
           dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE('INEX', 'EXPT', n.SourceIncome_CODE) AS desc_income_source
      FROM INCM_Y1 n
     WHERE n.MemberMci_IDNO IN (SELECT m.MemberMci_IDNO
                                  FROM CMEM_Y1 AS m,
                                       CASE_Y1 AS c
                                 WHERE c.Case_IDNO = m.Case_IDNO
                                   AND c.Case_IDNO = @An_Case_IDNO
                                   AND m.Applicant_CODE = 'C')
       AND n.EndValidity_DATE = @Ld_High_DATE

   OPEN Ls_PetIncomeExpences_Cur

   FETCH NEXT FROM Ls_PetIncomeExpences_Cur INTO @Lc_PetIncomeExpensecur_CODE, @Ln_PetIncomeExpensecur_AMNT, @Ls_Desc_PetIncomeExpensecur_CODE

   WHILE @@FETCH_STATUS = 0
    BEGIN
     IF @Lc_PetIncomeExpensecur_CODE = @Lc_SourceIncExpSi_CODE
      BEGIN
       SET @Ls_Desc_PetIncomeExpensecur_CODE= ' '
       SET @Ln_sIIncomeExpense_AMNT = @Ln_PetIncomeExpensecur_AMNT
       SET @Ls_sIDescriptionIncomeSource_CODE = @Ls_Desc_PetIncomeExpensecur_CODE
      END
     ELSE IF @Lc_PetIncomeExpensecur_CODE = @Lc_SourceIncExpPa_CODE
      BEGIN
       SET @Ln_PaIncomeExpense_AMNT = @Ln_PetIncomeExpensecur_AMNT
       SET @Ls_PaDescriptionIncomeSource_CODE = @Ls_Desc_PetIncomeExpensecur_CODE
      END
     ELSE IF @Lc_PetIncomeExpensecur_CODE IN (@Lc_SourceIncExpEm_CODE, @Lc_SourceIncExpSe_CODE)
      BEGIN
       SET @Ln_EmSeIncomeExpense_AMNT = @Ln_PetIncomeExpensecur_AMNT
       SET @Ls_EmDescriptionIncomeSource_CODE = @Ls_Desc_PetIncomeExpensecur_CODE
      END
     ELSE IF @Lc_PetIncomeExpensecur_CODE = @Lc_SourceIncExpCo_CODE
      BEGIN
       SET @Ln_CoIncomeExpense_AMNT = @Ln_PetIncomeExpensecur_AMNT
       SET @Ls_CoDescriptionIncomeSource_CODE = @Ls_Desc_PetIncomeExpensecur_CODE
      END
     ELSE IF @Lc_PetIncomeExpensecur_CODE = @Lc_SourceIncExpUe_CODE
      BEGIN
       SET @Ln_UeIncomeExpense_AMNT = @Ln_PetIncomeExpensecur_AMNT
       SET @Ls_UeDescriptionIncomeSource_CODE = @Ls_Desc_PetIncomeExpensecur_CODE
      END
     ELSE IF @Lc_PetIncomeExpensecur_CODE = @Lc_SourceIncExpWc_CODE
      BEGIN
       SET @Ln_WcIncomeExpense_AMNT = @Ln_PetIncomeExpensecur_AMNT
       SET @Ls_WcDescriptionIncomeSource_CODE = @Ls_Desc_PetIncomeExpensecur_CODE
      END
     ELSE IF @Lc_PetIncomeExpensecur_CODE IN (@Lc_SourceIncExpSd_CODE, @Lc_SourceIncExpDi_CODE)
      BEGIN
       SET @Ln_SdDiIncomeExpense_AMNT = @Ln_PetIncomeExpensecur_AMNT
       SET @Ls_SdDescriptionIncomeSource_CODE = @Ls_Desc_PetIncomeExpensecur_CODE
      END
     ELSE IF @Lc_PetIncomeExpensecur_CODE = @Lc_SourceIncExpSs_CODE
      BEGIN
       SET @Ln_SsIncomeExpense_AMNT = @Ln_PetIncomeExpensecur_AMNT
       SET @Ls_SsDescriptionIncomeSource_CODE = @Ls_Desc_PetIncomeExpensecur_CODE
      END
     ELSE IF @Lc_PetIncomeExpensecur_CODE = @Lc_SourceIncExpDv_CODE
      BEGIN
       SET @Ln_DvIncomeExpense_AMNT = @Ln_PetIncomeExpensecur_AMNT
       SET @Ls_DvDescriptionIncomeSource_CODE = @Ls_Desc_PetIncomeExpensecur_CODE
      END
     ELSE IF @Lc_PetIncomeExpensecur_CODE IN (@Lc_SourceIncExpAn_CODE, @Lc_SourceIncExpTi_CODE)
      BEGIN
       SET @Ln_AnTiIncomeExpense_AMNT = @Ln_PetIncomeExpensecur_AMNT
       SET @Ls_AnDescriptionIncomeSource_CODE = @Ls_Desc_PetIncomeExpensecur_CODE
      END
     ELSE IF @Lc_PetIncomeExpensecur_CODE IN (@Lc_SourceIncExpPe_CODE, @Lc_SourceIncExpRe_CODE, @Lc_SourceIncExpRr_CODE)
      BEGIN
       SET @Ln_PeReIncomeExpense_AMNT = @Ln_PetIncomeExpensecur_AMNT
       SET @Ls_PeDescriptionIncomeSource_CODE = @Ls_Desc_PetIncomeExpensecur_CODE
      END
     ELSE IF @Lc_PetIncomeExpensecur_CODE = @Lc_SourceIncExpAl_CODE
      BEGIN
       SET @Ln_AlIncomeExpense_AMNT = @Ln_PetIncomeExpensecur_AMNT
       SET @Ls_AlDescriptionIncomeSource_CODE = @Ls_Desc_PetIncomeExpensecur_CODE
      END

     FETCH NEXT FROM Ls_PetIncomeExpences_Cur INTO @Lc_PetIncomeExpensecur_CODE, @Ln_PetIncomeExpensecur_AMNT, @Ls_Desc_PetIncomeExpensecur_CODE
    END

   CLOSE Ls_PetIncomeExpences_Cur

   DEALLOCATE Ls_PetIncomeExpences_Cur

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT Element_NAME,
           Element_VALUE
      FROM (SELECT CONVERT(VARCHAR(100), PETITIONER_SI_INCOME) PETITIONER_SI_INCOME_AMNT,
                   CONVERT(VARCHAR(100), PETITIONER_PA_INCOME) PETITIONER_PA_INCOME_AMNT,
                   CONVERT(VARCHAR(100), PETITIONER_EM_SE_INCOME) PETITIONER_EM_SE_INCOME_AMNT,
                   CONVERT(VARCHAR(100), PETITIONER_CO_INCOME) PETITIONER_CO_INCOME_AMNT,
                   CONVERT(VARCHAR(100), PETITIONER_UE_INCOME) PETITIONER_UE_INCOME_AMNT,
                   CONVERT(VARCHAR(100), PETITIONER_WC_INCOME) PETITIONER_WC_INCOME_AMNT,
                   CONVERT(VARCHAR(100), PETITIONER_SD_INCOME) PETITIONER_SD_DI_INCOME_AMNT,
                   CONVERT(VARCHAR(100), PETITIONER_SS_INCOME) PETITIONER_SS_INCOME_AMNT,
                   CONVERT(VARCHAR(100), PETITIONER_DV_INCOME) PETITIONER_DV_INCOME_AMNT,
                   CONVERT(VARCHAR(100), PETITIONER_AN_INCOME) PETITIONER_AN_TI_INCOME_AMNT,
                   CONVERT(VARCHAR(100), PETITIONER_PE_RE_RR_INCOME) PETITIONER_PE_RE_RR_INCOME_AMNT,
                   CONVERT(VARCHAR(100), PETITIONER_AL_INCOME) PETITIONER_AL_INCOME_AMNT,
                   CONVERT(VARCHAR(100), PETITIONER_TOTAL_INCOME_AMNT) PETITIONER_TOTAL_INCOME_AMNT
              FROM (SELECT @Ln_sIIncomeExpense_AMNT AS PETITIONER_SI_INCOME,
                           @Ln_PaIncomeExpense_AMNT AS PETITIONER_PA_INCOME,
                           @Ln_EmSeIncomeExpense_AMNT AS PETITIONER_EM_SE_INCOME,
                           @Ln_CoIncomeExpense_AMNT AS PETITIONER_CO_INCOME,
                           @Ln_UeIncomeExpense_AMNT AS PETITIONER_UE_INCOME,
                           @Ln_WcIncomeExpense_AMNT AS PETITIONER_WC_INCOME,
                           @Ln_SdDiIncomeExpense_AMNT AS PETITIONER_SD_INCOME,
                           @Ln_SsIncomeExpense_AMNT AS PETITIONER_SS_INCOME,
                           @Ln_DvIncomeExpense_AMNT AS PETITIONER_DV_INCOME,
                           @Ln_AnTiIncomeExpense_AMNT AS PETITIONER_AN_INCOME,
                           @Ln_PeReIncomeExpense_AMNT AS PETITIONER_PE_RE_RR_INCOME,
                           @Ls_PeDescriptionIncomeSource_CODE AS PETITIONER_PR_RE_RR_DESC_INCOME,
                           @Ln_AlIncomeExpense_AMNT AS PETITIONER_AL_INCOME,
                           (@Ln_sIIncomeExpense_AMNT + @Ln_PaIncomeExpense_AMNT + @Ln_EmSeIncomeExpense_AMNT + @Ln_CoIncomeExpense_AMNT + @Ln_UeIncomeExpense_AMNT + @Ln_WcIncomeExpense_AMNT + @Ln_SdDiIncomeExpense_AMNT + @Ln_SsIncomeExpense_AMNT + @Ln_DvIncomeExpense_AMNT + @Ln_AnTiIncomeExpense_AMNT) AS PETITIONER_TOTAL_INCOME_AMNT)a) up UNPIVOT (Element_VALUE FOR Element_NAME IN ( PETITIONER_SI_INCOME_AMNT, PETITIONER_PA_INCOME_AMNT, PETITIONER_EM_SE_INCOME_AMNT, PETITIONER_CO_INCOME_AMNT, PETITIONER_UE_INCOME_AMNT, PETITIONER_WC_INCOME_AMNT, PETITIONER_SD_DI_INCOME_AMNT, PETITIONER_SS_INCOME_AMNT, PETITIONER_DV_INCOME_AMNT, PETITIONER_AN_TI_INCOME_AMNT, PETITIONER_PE_RE_RR_INCOME_AMNT, PETITIONER_AL_INCOME_AMNT, PETITIONER_TOTAL_INCOME_AMNT )) AS pvt);

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
  END CATCH
 END


GO
