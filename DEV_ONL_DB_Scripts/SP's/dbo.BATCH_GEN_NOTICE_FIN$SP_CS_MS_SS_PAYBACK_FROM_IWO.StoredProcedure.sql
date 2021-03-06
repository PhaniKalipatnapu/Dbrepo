/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_FIN$SP_CS_MS_SS_PAYBACK_FROM_IWO]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_FIN$SP_CS_MS_SS_PAYBACK_FROM_IWO
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	4/19/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_FIN$SP_CS_MS_SS_PAYBACK_FROM_IWO] (  
 @An_Case_IDNO             NUMERIC(6),  
 @An_OrderSeq_NUMB         NUMERIC(2),  
 @An_OtherParty_IDNO       NUMERIC(9),  
 @Ad_Run_DATE              DATE,  
 @Ac_ActivityMinor_CODE    CHAR(5),  
 @Ac_ReasonStatus_CODE     CHAR(2),  
 @Ac_StatusNotice_CODE     CHAR(1),  
 @Ac_Job_ID				    CHAR(7),   
 @Ac_Msg_CODE              CHAR(5) OUTPUT,  
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT  
 )  
AS  
 BEGIN  
 SET NOCOUNT ON;  
  DECLARE @Li_Error_NUMB               INT = NULL,  
          @Li_ErrorLine_NUMB           INT = NULL,  
          @Lc_Space_TEXT               CHAR(1) = ' ',  
          @Lc_Yes_TEXT                 CHAR(1) = 'Y',  
          @Lc_Weekly_TEXT              CHAR(1) = 'W',  
          @Lc_Semimonthly_TEXT         CHAR(1) = 'S',  
          @Lc_Monthly_TEXT             CHAR(1) = 'M',  
          @Lc_Quarterly_TEXT           CHAR(1) = 'Q',  
          @Lc_Annual_TEXT              CHAR(1) = 'A',  
          @Lc_No_TEXT                  CHAR(1) = 'N',  
          @Lc_One_Time_TEXT            CHAR(1) = 'O',  
          @Lc_StatusSuccess_CODE       CHAR(1) = 'S',  
          @Lc_StatusFailed_CODE        CHAR(1) = 'F',  
          @Lc_StatusNotice_CODE        CHAR(1) = 'V',  
          @Lc_Biweekly_TEXT            CHAR(1) = 'B',  
          @Lc_Value_TEXT               CHAR(1) = 'X',  
          @Lc_IwnStatusT1_CODE         CHAR(1) = 'T',  
          @Lc_IwnStatusA1_CODE         CHAR(1) = 'A',  
          @Lc_DebtTypeSpousalSupp_CODE CHAR(2) = 'SS',  
          @Lc_DebtTypeMedicalSupp_CODE CHAR(2) = 'MS',  
          @Lc_ReasonStatusGr_CODE      CHAR(2) = 'GR',  
          @Lc_ReasonStatusNz_CODE      CHAR(2) = 'NZ',  
          @Lc_TableFrqa_IDNO           CHAR(4) = 'FRQA',
          @Lc_NPROJob_ID			   CHAR(4) = 'NPRO',				  
          @Lc_TableSubFrq3_IDNO        CHAR(4) = 'FRQ3',  
          @Lc_ActivityMinorMpcoa_CODE  CHAR(5) = 'MPCOA',  
		  @Lc_ActivityMinorNopri_CODE  CHAR(5) = 'NOPRI',  
          @Ld_High_DATE                DATE = '12/31/9999';  
  DECLARE @Ln_CsIwo_AMNT                    NUMERIC(11, 2),  
          @Ln_SsIwo_AMNT                    NUMERIC(11, 2),  
          @Ln_MdIwo_AMNT                    NUMERIC(11, 2),  
          @Ln_OtIwo_AMNT                    NUMERIC(11, 2),  
          @Ln_PaybackIwo_AMNT               NUMERIC(11, 2),  
          @Ln_MdIwoPb_AMNT                  NUMERIC(11, 2),  
          @Ln_PercentWithheld_NUMB          NUMERIC(11, 2),  
          @Ln_WithheldWeekly_AMNT           NUMERIC(11, 2),  
          @Ln_WithheldBiweekly_AMNT         NUMERIC(11, 2),  
          @Ln_WithheldSemimonthly_AMNT      NUMERIC(11, 2),  
          @Ln_WithheldAmountly_AMNT         NUMERIC(11, 2),  
          @Ln_Withhold_AMNT                 NUMERIC(11, 2),  
          @Ln_Balance_AMNT                  NUMERIC(11, 2),  
          @Ln_SsIwoPb_AMNT                  NUMERIC(11, 2),  
          @Ln_Zero_NUMB                     NUMERIC(11, 2) = 0,  
          @Ln_Monthly_AMNT                  NUMERIC(11, 2),  
          @Lc_Empty_TEXT                    CHAR(1) = '',  
          @Lc_FreqSs_CODE                   CHAR(1) = '',  
          @Lc_FreqCs_CODE                   CHAR(1) = '',  
          @Lc_FreqMd_CODE                   CHAR(1) = '',  
          @Lc_FreqOt_CODE                   CHAR(1) = '',  
          @Lc_FreqPayback_CODE              CHAR(1) = '',  
          @Lc_FreqPeriodic_CODE             CHAR(1) = '',  
          @Lc_Terminated_INDC               CHAR(1) = '',  
          @Lc_CheckBox1_TEXT           CHAR(1) = '',  
          @Lc_CheckBox2_TEXT                CHAR(1) = '',  
          @Lc_FlagTypeDebt_IDNO             CHAR(2) = '',  
          @Lc_Reason_CODE                   CHAR(5) = '',  
          @Ls_FrequencyPeriodic_CODE        VARCHAR(100) = '',  
          @Ls_Procedure_NAME                VARCHAR(100),  
          @Ls_MdDescriptionFreqPayback_TEXT VARCHAR(100),  
          @Ls_SsDescriptionFreqPayback_TEXT VARCHAR(100),  
          @Ls_DescriptionFreqCs_TEXT        VARCHAR(100),  
          @Ls_DescriptionFreqSs_TEXT        VARCHAR(100),  
          @Ls_DescriptionFreqMd_TEXT        VARCHAR(100),  
          @Ls_FreqWithhold_TEXT             VARCHAR(100),  
          @Ls_FreqOther_TEXT                VARCHAR(100),  
          @Ls_FreqPer_CODE                  VARCHAR(100),  
          @Ls_Sql_TEXT                      VARCHAR(200),  
          @Ls_Sqldata_TEXT                  VARCHAR(400),  
          @Ls_DescriptionError_TEXT         VARCHAR(4000);  
  
  BEGIN TRY  
   SET @Ln_CsIwo_AMNT = 0;  
   SET @Ln_SsIwo_AMNT = 0;  
   SET @Ln_MdIwo_AMNT = 0;  
   SET @Ln_OtIwo_AMNT = 0;  
   SET @Ln_PaybackIwo_AMNT = 0;  
   SET @Ln_MdIwoPb_AMNT = 0;  
   SET @Ls_MdDescriptionFreqPayback_TEXT = '';  
   SET @Ln_SsIwoPb_AMNT = 0;  
   SET @Ls_SsDescriptionFreqPayback_TEXT = '';  
   SET @Ls_DescriptionFreqCs_TEXT = '';  
   SET @Ls_DescriptionFreqSs_TEXT = '';  
   SET @Ls_DescriptionFreqMd_TEXT = '';  
   SET @Ls_FrequencyPeriodic_CODE = '';  
   SET @Ln_Balance_AMNT = 0;  
   SET @Lc_CheckBox1_TEXT = '';  
   SET @Lc_CheckBox2_TEXT = '';  
   SET @Lc_Reason_CODE = '';  
   SET @Ln_PercentWithheld_NUMB = 0;  
   SET @Ln_WithheldWeekly_AMNT = 0;  
   SET @Ln_WithheldBiweekly_AMNT = 0;  
   SET @Ln_WithheldSemimonthly_AMNT = 0;  
   SET @Ln_WithheldAmountly_AMNT = NULL;  
   SET @Ln_Withhold_AMNT = 0;  
   SET @Ls_FreqWithhold_TEXT = '';  
   SET @Ls_FreqOther_TEXT = '';  
   SET @Ac_Msg_CODE = '';  
   SET @As_DescriptionError_TEXT = '';  
   SET @Ls_Procedure_NAME = 'BATCH_GEN_NOTICE_FIN$SP_CS_MS_SS_PAYBACK_FROM_IWO ';  
    
   IF ((@Ac_ActivityMinor_CODE = @Lc_ActivityMinorMpcoa_CODE  
       AND (@Ac_ReasonStatus_CODE = @Lc_ReasonStatusGr_CODE  
             OR @Ac_ReasonStatus_CODE = @Lc_ReasonStatusNz_CODE))
        OR (@Ac_ActivityMinor_CODE = @Lc_ActivityMinorNopri_CODE AND @Ac_Job_ID!=@Lc_NPROJob_ID))               
      AND @Ac_StatusNotice_CODE != @Lc_StatusNotice_CODE  
    BEGIN  
     SET @Ln_CsIwo_AMNT = 0;  
     SET @Ln_SsIwo_AMNT = 0;  
     SET @Ln_MdIwo_AMNT = 0;  
     SET @Ln_OtIwo_AMNT = 0;  
     SET @Ln_PaybackIwo_AMNT = 0;  
     SET @Ls_FreqPer_CODE = @Lc_Space_TEXT;  
     SET @Lc_FreqCs_CODE = @Lc_Space_TEXT;  
     SET @Lc_FreqSs_CODE = @Lc_Space_TEXT;  
     SET @Lc_FreqMd_CODE = @Lc_Space_TEXT;  
     SET @Lc_FreqOt_CODE = @Lc_Space_TEXT;  
     SET @Lc_FreqPayback_CODE = @Lc_Space_TEXT;  
     SET @Ls_DescriptionFreqCs_TEXT = 0;  
     SET @Ls_DescriptionFreqSs_TEXT = 0;  
     SET @Ls_DescriptionFreqMd_TEXT = 0;  
     SET @Ls_FreqOther_TEXT = @Lc_Space_TEXT;  
     SET @Ls_MdDescriptionFreqPayback_TEXT = @Lc_Space_TEXT;  
     SET @Lc_CheckBox1_TEXT = @Lc_Space_TEXT;  
     SET @Lc_Terminated_INDC = @Lc_Yes_TEXT;  
     SET @Ls_Sql_TEXT = 'SELECT IWEM_Y1_1';  
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6)) + ', OtherParty_IDNO = ' + CAST(ISNULL(@An_OtherParty_IDNO, 0) AS VARCHAR(9));  
     
   SELECT TOP 1 @Ln_CsIwo_AMNT = w.CurCs_AMNT,  
            @Ln_SsIwo_AMNT = w.CurSs_AMNT,  
            @Ln_MdIwo_AMNT = w.CurMd_AMNT,  
            @Ln_OtIwo_AMNT = w.CurOt_AMNT,  
            @Ln_PaybackIwo_AMNT = w.Payback_AMNT,  
            @Ls_FreqPer_CODE = (ISNULL(w.FreqCs_CODE, @Lc_Empty_TEXT) + ISNULL(w.FreqSs_CODE, @Lc_Empty_TEXT) + ISNULL(w.FreqMd_CODE, @Lc_Empty_TEXT) + ISNULL(w.FreqOt_CODE, @Lc_Empty_TEXT) + ISNULL(w.FreqPayback_CODE, @Lc_Empty_TEXT)),  
            @Lc_FreqCs_CODE = w.FreqCs_CODE,  
            @Lc_FreqSs_CODE = w.FreqSs_CODE,  
            @Lc_FreqMd_CODE = w.FreqMd_CODE,  
            @Lc_FreqOt_CODE = w.FreqOt_CODE,  
            @Lc_FreqPayback_CODE = w.FreqPayback_CODE,  
            @Ls_DescriptionFreqCs_TEXT = dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC(@Lc_TableFrqa_IDNO, @Lc_TableSubFrq3_IDNO, w.FreqCs_CODE),  
            @Ls_DescriptionFreqSs_TEXT = dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC(@Lc_TableFrqa_IDNO, @Lc_TableSubFrq3_IDNO, w.FreqSs_CODE),  
            @Ls_DescriptionFreqMd_TEXT = dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC(@Lc_TableFrqa_IDNO, @Lc_TableSubFrq3_IDNO, w.FreqMd_CODE),  
            @Ls_FreqOther_TEXT = dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC(@Lc_TableFrqa_IDNO, @Lc_TableSubFrq3_IDNO, w.FreqOt_CODE),  
            @Ls_MdDescriptionFreqPayback_TEXT = dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC(@Lc_TableFrqa_IDNO, @Lc_TableSubFrq3_IDNO, w.FreqPayback_CODE),  
            @Lc_CheckBox1_TEXT = w.ArrearAged_INDC  
       FROM Iwem_Y1 w  
      WHERE w.Case_IDNO = @An_Case_IDNO  
        AND w.IwnStatus_CODE IN( @Lc_IwnStatusT1_CODE  ,@Lc_IwnStatusA1_CODE)
        AND w.OthpEmployer_IDNO = @An_OtherParty_IDNO  
        AND w.EndValidity_DATE = @Ld_High_DATE
        ORDER BY w.TransactionEventSeq_NUMB DESC;  
    END  
   ELSE  
    BEGIN  
     SET @Ls_Sql_TEXT = 'SELECT IWEM_Y1_2';  
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6)) + ', OtherParty_IDNO = ' + CAST(ISNULL(@An_OtherParty_IDNO, 0) AS VARCHAR(9));  

  IF @Ac_Job_ID!=@Lc_NPROJob_ID
  BEGIN   
    SELECT @Ln_CsIwo_AMNT = w.CurCs_AMNT,  
            @Ln_SsIwo_AMNT = w.CurSs_AMNT,  
            @Ln_MdIwo_AMNT = w.CurMd_AMNT,  
            @Ln_OtIwo_AMNT = w.CurOt_AMNT,  
            @Ln_PaybackIwo_AMNT = w.Payback_AMNT,  
            @Ls_FreqPer_CODE = (ISNULL(w.FreqCs_CODE, @Lc_Empty_TEXT) + ISNULL(w.FreqSs_CODE, @Lc_Empty_TEXT) + ISNULL(w.FreqMd_CODE, @Lc_Empty_TEXT) + ISNULL(w.FreqOt_CODE, @Lc_Empty_TEXT) + ISNULL(w.FreqPayback_CODE, @Lc_Empty_TEXT)),  
            @Lc_FreqCs_CODE = w.FreqCs_CODE,  
            @Lc_FreqSs_CODE = w.FreqSs_CODE,  
            @Lc_FreqMd_CODE = w.FreqMd_CODE,  
            @Lc_FreqOt_CODE = w.FreqOt_CODE,  
            @Lc_FreqPayback_CODE = w.FreqPayback_CODE,  
            @Ls_DescriptionFreqCs_TEXT = dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC(@Lc_TableFrqa_IDNO, @Lc_TableSubFrq3_IDNO, w.FreqCs_CODE),  
            @Ls_DescriptionFreqSs_TEXT = dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC(@Lc_TableFrqa_IDNO, @Lc_TableSubFrq3_IDNO, w.FreqSs_CODE),  
            @Ls_DescriptionFreqMd_TEXT = dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC(@Lc_TableFrqa_IDNO, @Lc_TableSubFrq3_IDNO, w.FreqMd_CODE),  
            @Ls_FreqOther_TEXT = dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC(@Lc_TableFrqa_IDNO, @Lc_TableSubFrq3_IDNO, w.FreqOt_CODE),  
            @Ls_MdDescriptionFreqPayback_TEXT = dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC(@Lc_TableFrqa_IDNO, @Lc_TableSubFrq3_IDNO, w.FreqPayback_CODE),  
            @Lc_CheckBox1_TEXT = w.ArrearAged_INDC  
       FROM Iwem_Y1 w  
      WHERE w.Case_IDNO = @An_Case_IDNO  
        AND w.OrderSeq_NUMB = @An_OrderSeq_NUMB  
        AND w.IwnStatus_CODE = @Lc_IwnStatusA1_CODE  
        AND w.OthpEmployer_IDNO = @An_OtherParty_IDNO  
        AND w.End_DATE = @Ld_High_DATE  
        AND w.EndValidity_DATE = @Ld_High_DATE;  
        

      END  
   ELSE  
   BEGIN  
	       SET @Ln_CsIwo_AMNT = 0;  
           SET @Ln_SsIwo_AMNT = 0;  
           SET @Ln_MdIwo_AMNT = 0;  
           SET @Ln_OtIwo_AMNT = 0;  
           SET @Ln_PaybackIwo_AMNT = 0;  
           SET @Ls_FreqPer_CODE = @Lc_Space_TEXT;  
           SET @Lc_FreqCs_CODE = @Lc_Space_TEXT;  
           SET @Lc_FreqSs_CODE = @Lc_Space_TEXT;  
           SET @Lc_FreqMd_CODE = @Lc_Space_TEXT;  
           SET @Lc_FreqOt_CODE = @Lc_Space_TEXT;  
           SET @Lc_FreqPayback_CODE = @Lc_Space_TEXT;  
           SET @Ls_DescriptionFreqCs_TEXT = @Lc_Space_TEXT;  
           SET @Ls_DescriptionFreqSs_TEXT = @Lc_Space_TEXT;  
           SET @Ls_DescriptionFreqMd_TEXT = @Lc_Space_TEXT;  
           SET @Ls_FreqOther_TEXT = @Lc_Space_TEXT;  
           SET @Ls_MdDescriptionFreqPayback_TEXT = @Lc_Space_TEXT;  
           SET @Lc_CheckBox1_TEXT = @Lc_Space_TEXT;  

		 SELECT
			   @Lc_CheckBox1_TEXT = w.ArrearAged_INDC  
		 FROM Iwem_Y1 w  
         WHERE w.Case_IDNO = @An_Case_IDNO  
           AND w.OrderSeq_NUMB = @An_OrderSeq_NUMB  
           AND w.IwnStatus_CODE = @Lc_IwnStatusA1_CODE  
           AND w.OthpEmployer_IDNO = @An_OtherParty_IDNO  
           AND w.End_DATE = @Ld_High_DATE  
           AND w.EndValidity_DATE = @Ld_High_DATE;  
        
   END  
   END  
  
   IF SUBSTRING(ISNULL(LTRIM(RTRIM(@Ls_FreqPer_CODE)), @Lc_Empty_TEXT), 1, 1) = @Lc_Weekly_TEXT  
    BEGIN  
     SET @Lc_FreqPeriodic_CODE = @Lc_Weekly_TEXT;  
    END  
   ELSE IF SUBSTRING(ISNULL(LTRIM(RTRIM(@Ls_FreqPer_CODE)), @Lc_Empty_TEXT), 1, 1) = @Lc_Biweekly_TEXT  
    BEGIN  
     SET @Lc_FreqPeriodic_CODE = @Lc_Biweekly_TEXT;  
    END  
   ELSE IF SUBSTRING(ISNULL(LTRIM(RTRIM(@Ls_FreqPer_CODE)), @Lc_Empty_TEXT), 1, 1) = @Lc_Semimonthly_TEXT  
    BEGIN  
     SET @Lc_FreqPeriodic_CODE = @Lc_Semimonthly_TEXT;  
    END  
   ELSE IF SUBSTRING(ISNULL(LTRIM(RTRIM(@Ls_FreqPer_CODE)), @Lc_Empty_TEXT), 1, 1) = @Lc_Monthly_TEXT  
    BEGIN  
     SET @Lc_FreqPeriodic_CODE = @Lc_Monthly_TEXT;  
    END  
   ELSE IF SUBSTRING(ISNULL(LTRIM(RTRIM(@Ls_FreqPer_CODE)), @Lc_Empty_TEXT), 1, 1) = @Lc_Quarterly_TEXT  
    BEGIN  
     SET @Lc_FreqPeriodic_CODE = @Lc_Quarterly_TEXT;  
    END  
   ELSE IF SUBSTRING(ISNULL(LTRIM(RTRIM(@Ls_FreqPer_CODE)), @Lc_Empty_TEXT), 1, 1) = @Lc_Annual_TEXT  
    BEGIN  
     SET @Lc_FreqPeriodic_CODE = @Lc_Annual_TEXT;  
    END 
   ELSE IF SUBSTRING(ISNULL(LTRIM(RTRIM(@Ls_FreqPer_CODE)), @Lc_Empty_TEXT), 1, 1) = @Lc_One_Time_TEXT    
    BEGIN    
     SET @Lc_FreqPeriodic_CODE = @Lc_One_Time_TEXT;    
    END    
   ELSE  
    BEGIN  
     SET @Lc_FreqPeriodic_CODE = @Lc_Empty_TEXT;  
    END  
  
   SELECT @Ln_Monthly_AMNT = ISNULL(SUM(CASE @Lc_FreqCs_CODE  
                                         WHEN @Lc_Weekly_TEXT  
                                          THEN (@Ln_CsIwo_AMNT * 52) / 12  
                                         WHEN @Lc_Monthly_TEXT  
                                          THEN @Ln_CsIwo_AMNT  
                                         WHEN @Lc_Biweekly_TEXT  
                                          THEN (@Ln_CsIwo_AMNT * 26) / 12  
                                         WHEN @Lc_Semimonthly_TEXT  
                                          THEN (@Ln_CsIwo_AMNT * 24) / 12  
                                         WHEN @Lc_Quarterly_TEXT  
                                          THEN (@Ln_CsIwo_AMNT * 4) / 12  
                                         WHEN @Lc_Annual_TEXT  
                                          THEN (@Ln_CsIwo_AMNT * 1) / 12  
                                         ELSE @Ln_CsIwo_AMNT  
                                        END), @Ln_Zero_NUMB) + ISNULL(SUM(CASE @Lc_FreqPayback_CODE  
                                                                           WHEN @Lc_Weekly_TEXT  
                                                                            THEN (@Ln_PaybackIwo_AMNT * 52) / 12  
                                                                           WHEN @Lc_Monthly_TEXT  
                                                                            THEN @Ln_PaybackIwo_AMNT  
                                                                           WHEN @Lc_Biweekly_TEXT  
                                                                            THEN (@Ln_PaybackIwo_AMNT * 26) / 12  
                                                                           WHEN @Lc_Semimonthly_TEXT  
                                                                            THEN (@Ln_PaybackIwo_AMNT * 24) / 12  
                                                                           WHEN @Lc_Quarterly_TEXT  
                                                                            THEN (@Ln_PaybackIwo_AMNT * 4) / 12  
                                                                           WHEN @Lc_Annual_TEXT  
                                                                            THEN (@Ln_PaybackIwo_AMNT * 1) / 12  
                                                                           ELSE @Ln_PaybackIwo_AMNT  
                                                                          END), @Ln_Zero_NUMB) + ISNULL(SUM(CASE @Lc_FreqOt_CODE  
                                                                                                             WHEN @Lc_Weekly_TEXT  
                                                                            THEN (@Ln_OtIwo_AMNT * 52) / 12  
                                                                                                             WHEN @Lc_Monthly_TEXT  
                                                                                                              THEN @Ln_OtIwo_AMNT  
                                                                                                             WHEN @Lc_Biweekly_TEXT  
                                                                                                              THEN (@Ln_OtIwo_AMNT * 26) / 12  
                                                                                                             WHEN @Lc_Semimonthly_TEXT  
                                                                                                              THEN (@Ln_OtIwo_AMNT * 24) / 12  
                                                                                                             WHEN @Lc_Quarterly_TEXT  
                                                                                                              THEN (@Ln_OtIwo_AMNT * 4) / 12  
                                                                                                             WHEN @Lc_Annual_TEXT  
                                                                                                              THEN (@Ln_OtIwo_AMNT * 1) / 12  
                                                                                                             ELSE @Ln_OtIwo_AMNT  
                                                                                                            END), @Ln_Zero_NUMB) + ISNULL(SUM(CASE @Lc_FreqSs_CODE  
                                                                                                                                               WHEN @Lc_Weekly_TEXT  
                                                                                                                                                THEN (@Ln_SsIwo_AMNT * 52) / 12  
                                                                                                                                               WHEN @Lc_Monthly_TEXT  
                                                                                                                                                THEN @Ln_SsIwo_AMNT  
                                                                                                                                               WHEN @Lc_Biweekly_TEXT  
                                                                                                                                                THEN (@Ln_SsIwo_AMNT * 26) / 12  
                                                                                                                                               WHEN @Lc_Semimonthly_TEXT  
                                                                                                                                                THEN (@Ln_SsIwo_AMNT * 24) / 12  
                                                                                                                                               WHEN @Lc_Quarterly_TEXT  
                                                                                                                                                THEN (@Ln_SsIwo_AMNT * 4) / 12  
                                                                                                                                               WHEN @Lc_Annual_TEXT  
                                                                                                                                                THEN (@Ln_SsIwo_AMNT * 1) / 12  
                                                                                                                                               ELSE @Ln_SsIwo_AMNT  
                                                                                                                             END), @Ln_Zero_NUMB) + ISNULL(SUM(CASE @Lc_FreqMd_CODE  
                                                                                                                                                                                 WHEN @Lc_Weekly_TEXT  
                                                                                                                                                                                  THEN (@Ln_MdIwo_AMNT * 52) / 12  
                                                                                                                                                                                 WHEN @Lc_Monthly_TEXT  
                                                                                                                                                                                  THEN @Ln_MdIwo_AMNT  
                                                                                                                                                                                 WHEN @Lc_Biweekly_TEXT  
                                                                                                                                                                                  THEN (@Ln_SsIwo_AMNT * 26) / 12  
                                                                                                                                                                                 WHEN @Lc_Semimonthly_TEXT  
                                                                                                                                                                                  THEN (@Ln_MdIwo_AMNT * 24) / 12  
                                                                                                                                                                                 WHEN @Lc_Quarterly_TEXT  
                                                                                                                                                                                  THEN (@Ln_MdIwo_AMNT * 4) / 12  
                                                                                                                                                                                 WHEN @Lc_Annual_TEXT  
                                                                                                                                                                                  THEN (@Ln_MdIwo_AMNT * 1) / 12  
                                                                                                                                                                                 ELSE @Ln_MdIwo_AMNT  
                                                                                                                                                                                END), @Ln_Zero_NUMB);  
  
   SELECT @Ln_Balance_AMNT = ISNULL(SUM(CASE @Lc_FreqPeriodic_CODE  
                                         WHEN @Lc_Weekly_TEXT  
                                          THEN (@Ln_Monthly_AMNT * 12) / 52  
                                         WHEN @Lc_Monthly_TEXT  
                                          THEN @Ln_Monthly_AMNT  
                                         WHEN @Lc_Biweekly_TEXT  
                                          THEN (@Ln_Monthly_AMNT * 12) / 26  
                                         WHEN @Lc_Semimonthly_TEXT  
                                          THEN (@Ln_Monthly_AMNT * 12) / 24  
                                         WHEN @Lc_Quarterly_TEXT  
                                          THEN (@Ln_Monthly_AMNT * 12) / 4  
                                         WHEN @Lc_Annual_TEXT  
                                          THEN (@Ln_Monthly_AMNT * 12)  
                                         ELSE @Ln_Monthly_AMNT  
                                        END), @Ln_Zero_NUMB);  
    IF @Ac_Job_ID !=@Lc_NPROJob_ID
	BEGIN
    IF @Lc_CheckBox1_TEXT = @Lc_Yes_TEXT  
     BEGIN  
       SET @Lc_CheckBox1_TEXT = @Lc_Value_TEXT;  
       SET @Lc_CheckBox2_TEXT = @Lc_Empty_TEXT;  
     END  
    ELSE  
     BEGIN  
       SET @Lc_CheckBox1_TEXT = @Lc_Empty_TEXT;  
       SET @Lc_CheckBox2_TEXT = @Lc_Value_TEXT;  
     END  
	 END
	 ELSE
	  BEGIN  
       SET @Lc_CheckBox1_TEXT = @Lc_Empty_TEXT;  
       SET @Lc_CheckBox2_TEXT = @Lc_Empty_TEXT;  
     END  
  
   IF @Ln_OtIwo_AMNT = @Ln_Zero_NUMB  
       OR @Ln_OtIwo_AMNT IS NULL  
    BEGIN  
     SET @Lc_Reason_CODE = @Lc_Empty_TEXT;  
     SET @Ls_FreqOther_TEXT = @Lc_Empty_TEXT;  
    END  
  
   IF @Ln_CsIwo_AMNT = @Ln_Zero_NUMB  
       OR @Ln_CsIwo_AMNT IS NULL  
    BEGIN  
     SET @Ls_DescriptionFreqCs_TEXT = @Lc_Empty_TEXT;  
    END  
  
   IF @Ln_SsIwo_AMNT = @Ln_Zero_NUMB  
       OR @Ln_SsIwo_AMNT IS NULL  
    BEGIN  
     SET @Ls_DescriptionFreqSs_TEXT = @Lc_Empty_TEXT;  
    END  
  
   IF @Ln_MdIwo_AMNT = @Ln_Zero_NUMB  
       OR @Ln_MdIwo_AMNT IS NULL  
    BEGIN  
     SET @Ls_DescriptionFreqMd_TEXT = @Lc_Empty_TEXT;  
    END  
  
   IF @Ln_PaybackIwo_AMNT = @Ln_Zero_NUMB  
       OR @Ln_PaybackIwo_AMNT IS NULL  
    BEGIN  
     SET @Ls_MdDescriptionFreqPayback_TEXT = @Lc_Empty_TEXT;  
    END  
   ELSE  
    BEGIN  
     IF @Ln_CsIwo_AMNT > 0  
      BEGIN  
       SET @Ln_MdIwoPb_AMNT = 0;  
       SET @Ln_SsIwoPb_AMNT = 0;  
       SET @Ls_SsDescriptionFreqPayback_TEXT = @Lc_Empty_TEXT;  
      END  
     ELSE IF @Ln_SsIwo_AMNT > 0  
      BEGIN  
       SET @Ln_SsIwoPb_AMNT = @Ln_PaybackIwo_AMNT;  
       SET @Ln_MdIwoPb_AMNT = 0;  
      END  
     ELSE IF @Ln_MdIwo_AMNT > 0  
      BEGIN  
       SET @Ln_MdIwoPb_AMNT = @Ln_PaybackIwo_AMNT;  
       SET @Ln_SsIwoPb_AMNT = 0;    
       SET @Ls_SsDescriptionFreqPayback_TEXT = @Lc_Empty_TEXT;   
      END  
     ELSE  
      BEGIN  
       IF (@Ln_CsIwo_AMNT = @Ln_Zero_NUMB  
            OR @Ln_CsIwo_AMNT IS NULL)  
        BEGIN  
         SET @Lc_FlagTypeDebt_IDNO = dbo.BATCH_GEN_NOTICE_FIN$SF_GET_DEBT_TYPE_IWO_PAYBACK(@An_Case_IDNO, @An_OrderSeq_NUMB, @Ad_Run_DATE);  
  
         IF @Lc_FlagTypeDebt_IDNO = @Lc_DebtTypeSpousalSupp_CODE  
          BEGIN  
           SET @Ln_SsIwoPb_AMNT = @Ln_PaybackIwo_AMNT;  
           SET @Ln_MdIwoPb_AMNT = 0;  
          END  
         ELSE IF @Lc_FlagTypeDebt_IDNO = @Lc_DebtTypeMedicalSupp_CODE  
          BEGIN  
           SET @Ln_MdIwoPb_AMNT = @Ln_PaybackIwo_AMNT;  
           SET @Ln_SsIwoPb_AMNT = 0;  
           SET @Ls_SsDescriptionFreqPayback_TEXT = @Lc_Empty_TEXT;  
          END  
         ELSE  
          BEGIN  
           SET @Ln_MdIwoPb_AMNT = 0;  
           SET @Ln_SsIwoPb_AMNT = 0;  
           SET @Ls_SsDescriptionFreqPayback_TEXT = @Lc_Empty_TEXT;  
          END  
        END  
       ELSE  
        BEGIN  
         SET @Ln_MdIwoPb_AMNT = 0;  
         SET @Ln_SsIwoPb_AMNT = 0;  
         SET @Ls_SsDescriptionFreqPayback_TEXT = @Lc_Empty_TEXT;  
        END  
      END  
    END  
  
   SELECT @Ln_WithheldWeekly_AMNT = (@Ln_Monthly_AMNT * 12) / 52,  
          @Ln_WithheldAmountly_AMNT = @Ln_Monthly_AMNT,  
          @Ln_WithheldBiweekly_AMNT = (@Ln_Monthly_AMNT * 12) / 26,  
          @Ln_WithheldSemimonthly_AMNT = (@Ln_Monthly_AMNT * 12) / 24  
  
   SET @Ls_FrequencyPeriodic_CODE = dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC(@Lc_TableFrqa_IDNO, @Lc_TableSubFrq3_IDNO, @Lc_FreqPeriodic_CODE);  
   SET @Ls_Sql_TEXT = 'SELECT DEMO_Y1';  
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS CHAR);  
  
   SELECT @Ln_PercentWithheld_NUMB = CASE  
                                      WHEN ISNULL(LTRIM(RTRIM(d.SecondFamily_INDC)), @Lc_No_TEXT) = @Lc_Yes_TEXT  
                                           AND @Lc_CheckBox1_TEXT = @Lc_Value_TEXT  
                                       THEN 55  
                                      WHEN ISNULL(LTRIM(RTRIM(d.SecondFamily_INDC)), @Lc_No_TEXT) = @Lc_Yes_TEXT  
                                           AND @Lc_CheckBox1_TEXT = @Lc_Empty_TEXT  
                                       THEN 50  
                                      WHEN ISNULL(LTRIM(RTRIM(d.SecondFamily_INDC)), @Lc_No_TEXT) = @Lc_No_TEXT  
                                           AND @Lc_CheckBox1_TEXT = @Lc_Value_TEXT  
                                       THEN 65  
                                      WHEN ISNULL(LTRIM(RTRIM(d.SecondFamily_INDC)), @Lc_No_TEXT) = @Lc_No_TEXT  
                                           AND @Lc_CheckBox1_TEXT = @Lc_Empty_TEXT  
                                       THEN 60  
                                      ELSE 0  
                                     END  
     FROM Demo_Y1 d  
    WHERE d.MemberMci_IDNO = dbo.BATCH_COMMON$SF_GETNCPMEMBERFORACTIVECASE(@An_Case_IDNO);  
  
   IF @Lc_Terminated_INDC = @Lc_Yes_TEXT  
    BEGIN  
     SET @Ln_PercentWithheld_NUMB = 0;  
    END  
    
   INSERT INTO #NoticeElementsData_P1  
               (Element_NAME,  
                ELEMENT_VALUE)  
   (SELECT Element_NAME,  
           ELEMENT_VALUE  
      FROM (SELECT CAST(a.An_CsIwo_AMNT AS VARCHAR(100)) IWO_CS_AMNT,  
                   CAST(a.An_SsIwo_AMNT AS VARCHAR(100)) IWO_SS_AMNT,  
                   CAST(a.An_MdIwo_AMNT AS VARCHAR(100)) IWO_MD_AMNT,  
                   CAST(a.An_OtIwo_AMNT AS VARCHAR(100)) IWO_OTHER_AMNT,  
                   CAST(a.An_PaybackIwo_AMNT AS VARCHAR(100)) IWO_PAYBACK_AMNT,  
                   CAST(a.An_MdIwoPb_AMNT AS VARCHAR(100)) IWO_PAYBACK_MS_AMNT,  
                   CAST(a.As_MdDescriptionFreqPayback_TEXT AS VARCHAR(100)) IWO_FREQ_PAYBACK_MS_TEXT,  
                   CAST(a.An_SsIwoPb_AMNT AS VARCHAR(100)) IWO_PAYBACK_SS_AMNT,  
                   CAST(a.As_SsDescriptionFreqPayback_TEXT AS VARCHAR(100)) IWO_FREQ_PAYBACK_SS_TEXT,  
                   CAST(a.As_DescriptionFreqCs_TEXT AS VARCHAR(100)) IWO_FREQ_CS_TEXT,  
                   CAST(a.As_DescriptionFreqSs_TEXT AS VARCHAR(100)) IWO_FREQ_SS_TEXT,  
                   CAST(a.As_DescriptionFreqMd_TEXT AS VARCHAR(100)) IWO_FREQ_MD_TEXT,  
                   CAST(a.As_DescriptionFreqPayback_TEXT AS VARCHAR(100)) IWO_FREQ_PAYBACK_TEXT,  
                   CAST(a.Ac_FreqPeriodic_CODE AS VARCHAR(100)) IWO_FREQ_TEXT,  
                   CAST(a.An_Balance_AMNT AS VARCHAR(100)) IWO_TOTAL_AMNT,  
                   CAST(a.As_CheckBox1_TEXT AS VARCHAR(100)) IWO_IND_ARREARS_YES_CODE,  
                   CAST(a.As_CheckBox2_TEXT AS VARCHAR(100)) IWO_IND_ARREARS_NO_CODE,  
                   CAST(a.Ac_Reason_CODE AS VARCHAR(100)) IWO_REASON_OTHER_TEXT,  
                   CAST(a.An_PercentWithheld_NUMB AS VARCHAR(100)) WITHHOD_PERCENT_NUMB,  
                   CAST(a.An_WithheldWeekly_AMNT AS VARCHAR(100)) WITHHOLD_WEEKLY_AMNT,  
                   CAST(a.An_WithheldBiweekly_AMNT AS VARCHAR(100)) WITHHOLD_BIWEEKLY_AMNT,  
                   CAST(a.An_WithheldSemimonthly_AMNT AS VARCHAR(100)) WITHHOLD_SEMIMONTHLY_AMNT,  
                   CAST(a.An_WithheldAmountly_AMNT AS VARCHAR(100)) WITHHOLD_MONTHLY_AMNT,  
                   CAST(a.An_Withhold_AMNT AS VARCHAR(100)) WITHHOLD_AMNT,  
				   CAST(a.As_FreqWithhold_TEXT AS VARCHAR(100)) FREQ_WITHHOLD_TEXT,  
                   CAST(a.As_FreqOther_TEXT AS VARCHAR(100)) IWO_FREQ_OTHER_TEXT  
              FROM (	-- 13129 - CR0345 IWO Process Changes 20131226 - Fix - Start
						SELECT CASE  
                            WHEN @Ln_CsIwo_AMNT = 0  
                             THEN @Lc_Empty_TEXT  
                            ELSE CAST(@Ln_CsIwo_AMNT AS VARCHAR)  
                           END AS An_CsIwo_AMNT,  
                           CASE  
                            WHEN @Ln_SsIwo_AMNT = 0  
                             THEN @Lc_Empty_TEXT  
                            ELSE CAST(@Ln_SsIwo_AMNT AS VARCHAR)  
                           END AS An_SsIwo_AMNT,  
                           CASE  
                            WHEN @Ln_MdIwo_AMNT = 0  
                             THEN @Lc_Empty_TEXT  
                            ELSE CAST(@Ln_MdIwo_AMNT AS VARCHAR)  
                           END AS An_MdIwo_AMNT,  
                           CASE  
                            WHEN @Ln_OtIwo_AMNT = 0  
                             THEN @Lc_Empty_TEXT  
                            ELSE CAST(@Ln_OtIwo_AMNT AS VARCHAR)  
                           END AS An_OtIwo_AMNT,  
                           CASE  
                            WHEN @Ln_PaybackIwo_AMNT = 0  
                             THEN @Lc_Empty_TEXT  
                            ELSE CAST(@Ln_PaybackIwo_AMNT AS VARCHAR)  
                           END AS An_PaybackIwo_AMNT,  
                           CASE  
                            WHEN @Ln_MdIwoPb_AMNT = 0  
                             THEN @Lc_Empty_TEXT  
                            ELSE CAST(@Ln_MdIwoPb_AMNT AS VARCHAR)  
                           END AS An_MdIwoPb_AMNT,  
                           @Ls_MdDescriptionFreqPayback_TEXT AS As_MdDescriptionFreqPayback_TEXT,  
                           CASE  
                            WHEN @Ln_SsIwoPb_AMNT = 0  
                             THEN @Lc_Empty_TEXT  
                            ELSE CAST(@Ln_SsIwoPb_AMNT AS VARCHAR)  
                           END AS An_SsIwoPb_AMNT,  
                           @Ls_SsDescriptionFreqPayback_TEXT AS As_SsDescriptionFreqPayback_TEXT,  
                           @Ls_DescriptionFreqCs_TEXT AS As_DescriptionFreqCs_TEXT,  
                           @Ls_DescriptionFreqSs_TEXT AS As_DescriptionFreqSs_TEXT,  
                           @Ls_DescriptionFreqMd_TEXT AS As_DescriptionFreqMd_TEXT,  
                           @Ls_MdDescriptionFreqPayback_TEXT AS As_DescriptionFreqPayback_TEXT,  
                           CASE 
							WHEN @Ac_ReasonStatus_CODE IN(@Lc_ReasonStatusGr_CODE,@Lc_ReasonStatusNz_CODE) 
							 THEN @Lc_Empty_TEXT 
							ELSE @Ls_FrequencyPeriodic_CODE 
							END AS Ac_FreqPeriodic_CODE,  
                           CASE  
                            WHEN @Ln_Balance_AMNT = 0   
                             THEN @Lc_Empty_TEXT  
                            ELSE CAST(@Ln_Balance_AMNT AS VARCHAR)  
                           END AS An_Balance_AMNT,  
                           @Lc_CheckBox1_TEXT AS As_CheckBox1_TEXT,  
                           @Lc_CheckBox2_TEXT AS As_CheckBox2_TEXT,  
                           @Lc_Reason_CODE AS Ac_Reason_CODE,  
                           @Ln_PercentWithheld_NUMB AS An_PercentWithheld_NUMB,
                           CASE  
                            WHEN @Ac_ReasonStatus_CODE IN(@Lc_ReasonStatusGr_CODE,@Lc_ReasonStatusNz_CODE) OR @Ln_WithheldWeekly_AMNT = 0  
                             THEN @Lc_Empty_TEXT  
                            ELSE CAST(@Ln_WithheldWeekly_AMNT AS VARCHAR)  
                           END AS An_WithheldWeekly_AMNT,  
                           CASE  
                            WHEN @Ac_ReasonStatus_CODE IN(@Lc_ReasonStatusGr_CODE,@Lc_ReasonStatusNz_CODE) OR @Ln_WithheldBiweekly_AMNT = 0
                             THEN @Lc_Empty_TEXT  
                            ELSE CAST(@Ln_WithheldBiweekly_AMNT AS VARCHAR)  
                           END AS An_WithheldBiweekly_AMNT,  
                           CASE  
                            WHEN @Ac_ReasonStatus_CODE IN(@Lc_ReasonStatusGr_CODE,@Lc_ReasonStatusNz_CODE) OR @Ln_WithheldSemimonthly_AMNT = 0
                             THEN @Lc_Empty_TEXT  
                            ELSE CAST(@Ln_WithheldSemimonthly_AMNT AS VARCHAR)  
                           END AS An_WithheldSemimonthly_AMNT,  
                           CASE  
                            WHEN @Ac_ReasonStatus_CODE IN(@Lc_ReasonStatusGr_CODE,@Lc_ReasonStatusNz_CODE) OR @Ln_WithheldAmountly_AMNT = 0 
                             THEN @Lc_Empty_TEXT  
                            ELSE CAST(@Ln_WithheldAmountly_AMNT AS VARCHAR)  
                           END AS An_WithheldAmountly_AMNT,  
                           CASE  
                            WHEN @Ln_Withhold_AMNT = 0  
                             THEN @Lc_Empty_TEXT  
                            ELSE CAST(@Ln_Withhold_AMNT AS VARCHAR)  
                           END AS An_Withhold_AMNT,  
                           @Ls_FreqWithhold_TEXT AS As_FreqWithhold_TEXT,  
                           @Ls_FreqOther_TEXT AS As_FreqOther_TEXT)a)up UNPIVOT (ELEMENT_VALUE FOR Element_NAME IN ( IWO_CS_AMNT, IWO_SS_AMNT, IWO_MD_AMNT, IWO_OTHER_AMNT, IWO_PAYBACK_AMNT, IWO_PAYBACK_MS_AMNT, IWO_FREQ_PAYBACK_MS_TEXT, IWO_PAYBACK_SS_AMNT, IWO_FREQ_PAYBACK_SS_TEXT, IWO_FREQ_CS_TEXT, IWO_FREQ_SS_TEXT, IWO_FREQ_MD_TEXT, IWO_FREQ_PAYBACK_TEXT, IWO_FREQ_TEXT, IWO_TOTAL_AMNT, IWO_IND_ARREARS_YES_CODE, IWO_IND_ARREARS_NO_CODE, IWO_REASON_OTHER_TEXT, WITHHOD_PERCENT_NUMB, WITHHOLD_WEEKLY_AMNT,
						 WITHHOLD_BIWEEKLY_AMNT, WITHHOLD_SEMIMONTHLY_AMNT, WITHHOLD_MONTHLY_AMNT, WITHHOLD_AMNT, FREQ_WITHHOLD_TEXT, IWO_FREQ_OTHER_TEXT )) AS pvt);  
					-- 13129 - CR0345 IWO Process Changes 20131226 - Fix - End
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
