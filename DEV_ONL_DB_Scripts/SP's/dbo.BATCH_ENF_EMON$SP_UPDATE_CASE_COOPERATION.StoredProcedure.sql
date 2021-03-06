/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_UPDATE_CASE_COOPERATION]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    : BATCH_ENF_EMON$SP_UPDATE_CASE_COOPERATION
Programmer Name   : IMP Team
Description       : This procedure updates Cooperation Indicator, Cooperation Date , Good Cause Indicatorand Good 
                     Cause Date depending on reason choosed in Cooperation chain of Case Processor.
Frequency         :
Developed On      : 01/05/2012
Called By         : None
Called On         : 
--------------------------------------------------------------------------------------------------------------------
Modified By       :
Modified On       :
Version No        : 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_UPDATE_CASE_COOPERATION] (
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC(2),
 @An_MemberMci_IDNO           NUMERIC(10),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_ReasonStatus_CODE        CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_WorkerUpdate_ID          CHAR(30),
 @Ad_Run_DATE                 DATE,
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE @Lc_StatusSuccess_CODE		CHAR(1)			= 'S',
          @Lc_StatusFailed_CODE			CHAR(1)			= 'F',
          @Lc_GoodCauseApproved_CODE	CHAR(1)			= 'A',
          @Lc_GoodCauseDenied_CODE		CHAR(1)			= 'D',
          @Lc_NonCoopCooperation_CODE	CHAR(1)			= 'O',
          @Lc_NonCoopAdoption_CODE		CHAR(1)			= 'A',
          @Lc_NonCoopFailed_CODE		CHAR(1)			= 'P',
          @Lc_NonCoopHarmToCp_CODE		CHAR(1)			= 'C',
          @Lc_NonCoopHarmToChild_CODE	CHAR(1)			= 'K',
          @Lc_NonCoopRape_CODE			CHAR(1)			= 'R',
          @Lc_Space_TEXT				CHAR(1)			= ' ',
          @Lc_ReasonIl_CODE				CHAR(2)			= 'IL',
          @Lc_ReasonZw_CODE				CHAR(2)			= 'ZW',
          @Lc_ReasonCu_CODE				CHAR(2)			= 'CU',
          @Lc_ReasonFy_CODE				CHAR(2)			= 'FY',
          @Lc_ReasonCw_CODE				CHAR(2)			= 'CW',
          @Lc_ReasonHg_CODE				CHAR(2)			= 'HG',
          @Lc_ReasonDh_CODE				CHAR(2)			= 'DH',
          @Lc_ReasonDv_CODE				CHAR(2)			= 'DV',
          @Lc_ReasonDr_CODE				CHAR(2)			= 'DR',
          @Lc_ReasonDu_CODE				CHAR(2)			= 'DU',
          @Lc_ReasonDo_CODE				CHAR(2)			= 'DO',
          @Lc_ReasonCn_CODE				CHAR(2)			= 'CN',
          @Lc_StatusEnforceUcnc_CODE	CHAR(4)			= 'UCNC',	
          @Lc_ActivityMinorInfcp_CODE	CHAR(5)			= 'INFCP',
          @Lc_ActivityMinorCpint_CODE	CHAR(5)			= 'CPINT',
          @Lc_ActivityMinorAsagf_CODE	CHAR(5)			= 'ASAGF',
          @Lc_ActivityMinorEfgcf_CODE	CHAR(5)			= 'EFGCF',
          @Lc_ActivityMinorAgfaf_CODE	CHAR(5)			= 'AGFAF',
          @Ls_Routine_TEXT				VARCHAR(100)	= 'BATCH_ENF_EMON$SP_UPDATE_CASE_COOPERATION';
  DECLARE @Li_Error_NUMB				INT,
          @Li_ErrorLine_NUMB			INT,
          @Lc_StatusCase_CODE			CHAR(1),
          @Lc_NonCoop_CODE				CHAR(1),
          @Lc_GoodCause_CODE			CHAR(1),
          @Lc_StatusEnforce_CODE		CHAR(4),
          @Ls_Sql_TEXT					VARCHAR(100),
          @Ls_SqlData_TEXT				VARCHAR(200),
          @Ls_DescriptionError_TEXT		VARCHAR(4000),
          @Ld_NonCoop_DATE				DATE,
          @Ld_GoodCause_DATE			DATE;

  BEGIN TRY
   SET @Ls_Sql_TEXT= 'SELECT CASE_Y1,DMJR_Y1';
   SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@An_OrderSeq_NUMB AS VARCHAR(2)) + ', MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10));

   SELECT @Lc_StatusCase_CODE = c.StatusCase_CODE,
          @Lc_NonCoop_CODE = c.NonCoop_CODE,
          @Ld_NonCoop_DATE = c.NonCoop_DATE,
          @Lc_GoodCause_CODE = c.GoodCause_CODE,
          @Ld_GoodCause_DATE = c.GoodCause_DATE,
          @Lc_StatusEnforce_CODE = c.StatusEnforce_CODE
     FROM CASE_Y1 c
    WHERE c.Case_IDNO = @An_Case_IDNO;

   IF(@Ac_ActivityMinor_CODE IN (@Lc_ActivityMinorInfcp_CODE, @Lc_ActivityMinorCpint_CODE, @Lc_ActivityMinorAsagf_CODE)
      AND @Ac_ReasonStatus_CODE IN (@Lc_ReasonIl_CODE, @Lc_ReasonZw_CODE, @Lc_ReasonCu_CODE, @Lc_ReasonFy_CODE))
    BEGIN
     SET @Lc_NonCoop_CODE = @Lc_NonCoopCooperation_CODE;
     SET @Ld_NonCoop_DATE = @Ad_Run_DATE;
    END
   ELSE IF @Ac_ActivityMinor_CODE IN (@Lc_ActivityMinorCpint_CODE, @Lc_ActivityMinorAsagf_CODE, @Lc_ActivityMinorEfgcf_CODE, @Lc_ActivityMinorAgfaf_CODE)
      AND @Ac_ReasonStatus_CODE IN (@Lc_ReasonCw_CODE, @Lc_ReasonHg_CODE, @Lc_ReasonDo_CODE, @Lc_ReasonCn_CODE)
    BEGIN
     SET @Lc_NonCoop_CODE = @Lc_NonCoopFailed_CODE;
     SET @Ld_NonCoop_DATE = @Ad_Run_DATE;
     SET @Lc_GoodCause_CODE = @Lc_GoodCauseDenied_CODE;
     SET @Ld_GoodCause_DATE = @Ad_Run_DATE;
     SET @Lc_StatusEnforce_CODE = @Lc_StatusEnforceUcnc_CODE;
     
    END
   ELSE IF @Ac_ActivityMinor_CODE IN (@Lc_ActivityMinorEfgcf_CODE)
      AND @Ac_ReasonStatus_CODE IN (@Lc_ReasonDh_CODE)
    BEGIN
     SET @Lc_NonCoop_CODE = @Lc_NonCoopHarmToChild_CODE;
     SET @Ld_NonCoop_DATE = @Ad_Run_DATE;
     SET @Lc_GoodCause_CODE = @Lc_GoodCauseApproved_CODE;
     SET @Ld_GoodCause_DATE = @Ad_Run_DATE;
    END
   ELSE IF @Ac_ActivityMinor_CODE IN (@Lc_ActivityMinorEfgcf_CODE)
      AND @Ac_ReasonStatus_CODE IN (@Lc_ReasonDv_CODE)
    BEGIN
     SET @Lc_NonCoop_CODE = @Lc_NonCoopHarmToCp_CODE;
     SET @Ld_NonCoop_DATE = @Ad_Run_DATE;
     SET @Lc_GoodCause_CODE = @Lc_GoodCauseApproved_CODE;
     SET @Ld_GoodCause_DATE = @Ad_Run_DATE;
    END
   ELSE IF @Ac_ActivityMinor_CODE IN (@Lc_ActivityMinorEfgcf_CODE)
      AND @Ac_ReasonStatus_CODE IN (@Lc_ReasonDr_CODE)
    BEGIN
     SET @Lc_NonCoop_CODE = @Lc_NonCoopRape_CODE;
     SET @Ld_NonCoop_DATE = @Ad_Run_DATE;
     SET @Lc_GoodCause_CODE = @Lc_GoodCauseApproved_CODE;
     SET @Ld_GoodCause_DATE = @Ad_Run_DATE;
    END
   ELSE IF @Ac_ActivityMinor_CODE IN (@Lc_ActivityMinorEfgcf_CODE)
      AND @Ac_ReasonStatus_CODE IN (@Lc_ReasonDu_CODE)
    BEGIN
     SET @Lc_NonCoop_CODE = @Lc_NonCoopAdoption_CODE;
     SET @Ld_NonCoop_DATE = @Ad_Run_DATE;
     SET @Lc_GoodCause_CODE = @Lc_GoodCauseApproved_CODE;
     SET @Ld_GoodCause_DATE = @Ad_Run_DATE;
    END

   EXEC BATCH_COMMON$SP_UPDATE_CASE_DETAILS
    @An_Case_IDNO                = @An_Case_IDNO,
    @Ac_StatusCase_CODE          = @Lc_StatusCase_CODE,
    @Ac_GoodCause_CODE           = @Lc_GoodCause_CODE,
    @Ad_GoodCause_DATE			 = @Ld_GoodCause_DATE,
    @Ac_NonCoop_CODE             = @Lc_NonCoop_CODE,
    @Ad_NonCoop_DATE             = @Ad_Run_DATE,
    @Ac_StatusEnforce_CODE		 = @Lc_StatusEnforce_CODE,
    @Ac_WorkerUpdate_ID          = @Ac_WorkerUpdate_ID,
    @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
    @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF (@Ac_Msg_CODE != @Lc_StatusSuccess_CODE)
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @Ls_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
