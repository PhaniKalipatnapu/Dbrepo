/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BITABLES5B]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BITABLES5B
Programmer Name	:	IMP Team.
Description		:	This process loads the data from staging tables into BI tables.
Frequency		:	'DAILY'
Developed On	:	4/27/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BITABLES5B]
 @An_RecordCount_NUMB      NUMERIC(6) OUTPUT, 
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_QNTY  INT = 0,
          @Lc_Space_TEXT     CHAR(1) = ' ',
          @Lc_Failed_CODE    CHAR(1) = 'F',
          @Lc_Success_CODE   CHAR(1) = 'S',
          @Lc_TypeError_CODE CHAR(1) = 'E',
          @Lc_BateError_CODE CHAR(5) = 'E0944',
          @Lc_Job_ID         CHAR(7) = 'DEB1410',
          @Lc_Process_NAME   CHAR(14) = 'BATCH_BI_MAPCM',
          @Ls_Procedure_NAME VARCHAR(50) = 'SP_PROCESS_BITABLES5B';
  DECLARE @Ln_Zero_NUMB             NUMERIC(1) = 0,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Msg_CODE              CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Start_DATE            DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_Success_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'DELETE FROM BOBLE_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BOBLE_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BOBLE_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BOBLE_Y1
          (Case_IDNO,
           EndOfMonth_DATE,
           OpenObs_QNTY,
           TypeDebt_CODE,
           BeginObligation_DATE,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           EndObligation_DATE,
           Periodic_AMNT,
           FreqPeriodic_CODE,
           Ura_AMNT,
           MemberMci_IDNO)
   SELECT a.Case_IDNO,
          a.EndOfMonth_DATE,
          a.OpenObs_QNTY,
          a.TypeDebt_CODE,
          a.BeginObligation_DATE,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.EndObligation_DATE,
          a.Periodic_AMNT,
          a.FreqPeriodic_CODE,
          a.Ura_AMNT,
          a.MemberMci_IDNO
     FROM BPOBLE_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END   

   SET @Ls_Sql_TEXT = 'DELETE FROM BRMDY_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BRMDY_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BRMDY_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BRMDY_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           BiSubsystem_CODE,
           ActivityMajor_CODE,
           ActivityMinor_CODE,
           ActivityOrder_QNTY,
           Status_CODE,
           Status_DATE,
           DaysActivityElapsed_QNTY,
           BeginExempt_DATE,
           EndExempt_DATE,
           MajorIntSeq_NUMB,
           MinorIntSeq_NUMB,
           ReasonStatus_CODE,
           DescriptionActivityMajor_TEXT,
           DescriptionActivityMinor_TEXT,
           MemberMci_IDNO,
           TypeOthpSource_CODE,
           OthpSource_IDNO,
           TransactionEventMajorSeq_NUMB,
           TransactionEventMinorSeq_NUMB,
           StatusMinor_CODE,
           StatusMinor_DATE)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.BiSubsystem_CODE,
          a.ActivityMajor_CODE,
          a.ActivityMinor_CODE,
          a.ActivityOrder_QNTY,
          a.Status_CODE,
          a.Status_DATE,
          a.DaysActivityElapsed_QNTY,
          a.BeginExempt_DATE,
          a.EndExempt_DATE,
          a.MajorIntSeq_NUMB,
          a.MinorIntSeq_NUMB,
          a.ReasonStatus_CODE,
          a.DescriptionActivityMajor_TEXT,
          a.DescriptionActivityMinor_TEXT,
          a.MemberMci_IDNO,
          a.TypeOthpSource_CODE,
          a.OthpSource_IDNO,
          a.TransactionEventMajorSeq_NUMB,
          a.TransactionEventMinorSeq_NUMB,
          a.StatusMinor_CODE,
          a.StatusMinor_DATE
     FROM BPRMDY_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'DELETE FROM BMEMB_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BMEMB_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BMEMB_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BMEMB_Y1
          (Case_IDNO,
           MemberMci_IDNO,
           CaseRelationship_CODE,
           CaseMemberStatus_CODE,
           PaternityEst_CODE,
           StatusLocate_CODE,
           StatusChildOrder_CODE,
           MediumDisburse_CODE,
           Birth_DATE,
           Age_QNTY,
           NcpNsfBalance_AMNT,
           BornOfMarriage_INDC,
           FamilyViolenceIndc_CODE,
           NcpNsf_CODE,
           Ssn_CODE,
           ExcludeIrs_CODE,
           ExcludePas_CODE,
           ExcludeFin_CODE,
           ExcludeIns_CODE,
           ExcludeVen_CODE,
           ExcludeRet_CODE,
           ExcludeSal_CODE,
           ExcludeDebt_CODE,
           InsResonable_CODE,
           StatusLocate_DATE,
           MethodDisestablish_CODE)
   SELECT a.Case_IDNO,
          a.MemberMci_IDNO,
          a.CaseRelationship_CODE,
          a.CaseMemberStatus_CODE,
          a.PaternityEst_CODE,
          a.StatusLocate_CODE,
          a.StatusChildOrder_CODE,
          a.MediumDisburse_CODE,
          a.Birth_DATE,
          a.Age_QNTY,
          a.NcpNsfBalance_AMNT,
          a.BornOfMarriage_INDC,
          a.FamilyViolenceIndc_CODE,
          a.NcpNsf_CODE,
          a.Ssn_CODE,
          a.ExcludeIrs_CODE,
          a.ExcludePas_CODE,
          a.ExcludeFin_CODE,
          a.ExcludeIns_CODE,
          a.ExcludeVen_CODE,
          a.ExcludeRet_CODE,
          a.ExcludeSal_CODE,
          a.ExcludeDebt_CODE,
          a.InsResonable_CODE,
          a.StatusLocate_DATE,
          a.MethodDisestablish_CODE
     FROM BPMEMB_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
      
   SET @Ls_Sql_TEXT = 'DELETE FROM BEHSC_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BEHSC_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BEHSC_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BEHSC_Y1
          (Case_IDNO,
           MemberMci_IDNO,
           EndOfMonth_DATE,
           MonthlyNetIncome_AMNT,
           EhisEnd_DATE,
           Action_CODE,
           OthpPartyEmpl_IDNO,
           TransactionEventSeq_NUMB,
           BeginEmployment_DATE)
   SELECT a.Case_IDNO,
          a.MemberMci_IDNO,
          a.EndOfMonth_DATE,
          a.MonthlyNetIncome_AMNT,
          a.EhisEnd_DATE,
          a.Action_CODE,
          a.OthpPartyEmpl_IDNO,
          a.TransactionEventSeq_NUMB,
          a.BeginEmployment_DATE
     FROM BPEHSC_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
    
   SET @An_RecordCount_NUMB = (SELECT COUNT(*)
								 FROM (SELECT Case_IDNO
                                         FROM BOBLE_Y1
                                       UNION
                                       SELECT Case_IDNO
                                         FROM BRMDY_Y1
                                       UNION
                                       SELECT Case_IDNO
                                         FROM BMEMB_Y1
                                       UNION
                                       SELECT Case_IDNO
                                         FROM BEHSC_Y1) AS t);
    
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_Failed_CODE;
   SET @An_RecordCount_NUMB = 0;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END 

GO
