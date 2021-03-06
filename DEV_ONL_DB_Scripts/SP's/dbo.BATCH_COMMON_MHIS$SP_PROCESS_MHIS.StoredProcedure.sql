/****** Object:  StoredProcedure [dbo].[BATCH_COMMON_MHIS$SP_PROCESS_MHIS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*  
-----------------------------------------------------------------------------------------------------------------------------------------------  
Procedure Name    : BATCH_COMMON_MHIS$SP_PROCESS_MHIS 
Programmer Name   : IMP Team  
Description       : This procedure is used to Process the record for Mhis Change Record.  
Frequency         : DAILY  
Developed On      :	04/12/2011
Called BY         : None  
Called On         :   
------------------------------------------------------------------------------------------------------------------------------------------------  
Modified BY       :  
Modified On       :  
Version No        : 1.0  
----------------------------------------------------------------------------------------------------------------------------------------------  
*/
/*
1. XML Generation Query   
SELECT  
 MH.Start_DATE,  
 MH.End_DATE,  
 MH.TypeWelfare_CODE,  
 MH.CaseWelfare_IDNO,  
 MH.WelfareMemberMci_IDNO,  
 MH.Reason_CODE  
 FROM MHIS_Y1 MH  
 WHERE MH.MemberMci_IDNO = 245899   
    AND MH.Case_IDNO  = 100073  
FOR XML PATH('Record'), ELEMENTS  
  
2. XML Format  
     <root>  
          <Record>  
          </Record>  
			  <Record>  
			 <Start_DATE>2011-10-01</Start_DATE>  
			 <End_DATE>2011-10-31</End_DATE>  
			 <TypeWelfare_CODE>N</TypeWelfare_CODE>  
			 <CaseWelfare_IDNO>0</CaseWelfare_IDNO>  
			 <WelfareMemberMci_IDNO>0</WelfareMemberMci_IDNO>  
			 <Reason_CODE></Reason_CODE>  
			 <EventGlobalBeginSeq_NUMB>2255561</EventGlobalBeginSeq_NUMB>  
          </Record>  
          <Record>  
			 <Start_DATE>2011-09-01</Start_DATE>  
			 <End_DATE>2011-09-30</End_DATE>  
			 <TypeWelfare_CODE>A</TypeWelfare_CODE>  
			 <CaseWelfare_IDNO>9999100075</CaseWelfare_IDNO>  
			 <WelfareMemberMci_IDNO>0</WelfareMemberMci_IDNO>  
			 <Reason_CODE></Reason_CODE>  
			 <EventGlobalBeginSeq_NUMB>2255560</EventGlobalBeginSeq_NUMB>  
          </Record>  
      </root>   
    
 3. Excute Sample  
   
  DECLARE   
  @Ld_Today                 DATE  = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),  
  @Lc_Msg_CODE              CHAR(1),  
  @Ls_DescriptionError_TEXT VARCHAR(4000);  
  
  EXEC  BATCH_COMMON_MHIS$SP_PROCESS_MHIS 
  @An_MemberMci_IDNO = 245899,  
  @An_Case_IDNO = 100073,  
  @As_RhsMhisData_XML = '<root>  
		 <Record>  
			 <Start_DATE>2011-11-15</Start_DATE>  
			 <End_DATE>9999-12-31</End_DATE>  
			 <TypeWelfare_CODE>A</TypeWelfare_CODE>  
			 <CaseWelfare_IDNO>0</CaseWelfare_IDNO>  
			 <WelfareMemberMci_IDNO>0</WelfareMemberMci_IDNO>  
			 <Reason_CODE></Reason_CODE>  
          </Record>  
          <Record>  
			 <Start_DATE>2011-10-01</Start_DATE>  
			 <End_DATE>2011-11-15</End_DATE>  
			 <TypeWelfare_CODE>N</TypeWelfare_CODE>  
			 <CaseWelfare_IDNO>0</CaseWelfare_IDNO>  
			 <WelfareMemberMci_IDNO>0</WelfareMemberMci_IDNO>  
			 <Reason_CODE></Reason_CODE>  
          </Record>  
          <Record>  
			 <Start_DATE>2011-09-01</Start_DATE>  
			 <End_DATE>2011-09-30</End_DATE>  
			 <TypeWelfare_CODE>A</TypeWelfare_CODE>  
			 <CaseWelfare_IDNO>9999100075</CaseWelfare_IDNO>  
			 <WelfareMemberMci_IDNO>0</WelfareMemberMci_IDNO>  
			 <Reason_CODE></Reason_CODE>  
          </Record>  
       </root>',  
  @Ac_SignedOnWorker_ID = '',  
  @Ad_Run_DATE = @Ld_Today,  
  @Ac_Job_ID   = 'MHIS',  
  @Ac_Msg_CODE = @Lc_Msg_CODE OUTPUT,  
  @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;  
    
SELECT @Lc_Msg_CODE as Msg_CODE,  
  @Ls_DescriptionError_TEXT as DescriptionError_TEXT;   
  
GO  
**************/
CREATE PROCEDURE [dbo].[BATCH_COMMON_MHIS$SP_PROCESS_MHIS] (
 @An_Case_IDNO             NUMERIC(6),
 @An_MemberMci_IDNO        NUMERIC(10),
 @As_RhsMhisData_XML       XML,--Indicates the Xml data , of all modified Member Program for Case Member   
 @Ac_SignedOnWorker_ID     CHAR(30),
 @Ad_Run_DATE              DATE,
 @Ac_Job_ID                CHAR(7),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  DECLARE @Lt_LhsMhisData_TAB TABLE (
   Seq_IDNO              SMALLINT IDENTITY(1, 1) NOT NULL,
   [Start_DATE]          DATE,
   End_DATE              DATE,
   TypeWelfare_CODE      CHAR(1),
   CaseWelfare_IDNO      NUMERIC(10),
   WelfareMemberMci_IDNO NUMERIC(10),
   Reason_CODE           CHAR(2));
  DECLARE @Lt_RhsMhisData_TAB TABLE (
   Seq_IDNO              SMALLINT IDENTITY(1, 1) NOT NULL,
   [Start_DATE]          DATE,
   End_DATE              DATE,
   TypeWelfare_CODE      CHAR(1),
   CaseWelfare_IDNO      NUMERIC(10),
   WelfareMemberMci_IDNO NUMERIC(10),
   Reason_CODE           CHAR(2));
  DECLARE @Lt_MhisWel_TAB TABLE (
   Seq_IDNO         SMALLINT IDENTITY(1, 1) NOT NULL,
   Begin_DATE       DATE,
   CaseWelfare_IDNO NUMERIC(10));
  DECLARE @Ln_Zero_NUMB                            NUMERIC(19) = 0,
          @Lc_No_INDC                              CHAR(1) = 'N',
          @Lc_Yes_INDC                             CHAR(1) = 'Y',
          @Lc_StatusFailed_CODE                    CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE                   CHAR(1) = 'S',
          @Ls_DateFormatMmDdYyyy_TEXT              VARCHAR(10) = 'MM/DD/YYYY',
          @Lc_Space_TEXT                           CHAR(1) = ' ',
          @Ls_WelfareTypeTanf_CODE                 CHAR(1) = 'A',
          @Ld_High_DATE                            DATE = '12/31/9999',
          @Ls_MajorActivityCase_CODE               VARCHAR(4) = 'CASE',
          @Ls_HyphenWithSpace_TEXT                 VARCHAR(3) = ' - ',
          @Ls_DoubleSpace_TEXT                     VARCHAR(2) = '  ',
          @Ls_MsgChgNotAllowed_CODE                CHAR(1) = 'K',
          @Lc_Process_ID                           CHAR(10) = @Ac_Job_ID,
          --13736 - Correcting to variables standards -START-
          @Lc_TableMhis_ID                         CHAR(4) = 'MHIS',
          @Lc_TableSubPgty_ID                      CHAR(4) = 'PGTY',
          --13736 - Correcting to variables standards -END-
          @Lc_ActivityMinorUmhis_CODE              CHAR(5)= 'UMHIS',
          @Ls_CmSubsystem_TEXT                     VARCHAR(3) = 'CM',
          @Ls_Procedure_NAME                       VARCHAR(100) = 'BATCH_COMMON_MHIS$SP_PROCESS_MHIS',
          @Lc_ActivityMajorCase_CODE               CHAR(5) = 'CASE',
          @Lc_SubsystemCM_CODE                     CHAR(2) = 'CM',
          @Li_ParticipantTanfStatusChange2720_NUMB INT = 2720,
          @Li_CaseCategoryIsChanged5050_NUMB       INT = 5050,
          @Ls_Sql_TEXT                             VARCHAR(100),
          @Ls_Sqldata_TEXT                         VARCHAR(1000),
          @Ls_ErrorMessage_TEXT                    VARCHAR(500) = '',
          @Ls_DescriptionError_TEXT                VARCHAR(4000)= '',
          @Ln_MemberMci_IDNO                       NUMERIC(10),
          @Ld_OriginalMinLsupBegin_DATE            DATE,
          @Ld_MofifiedMinLsupBegin_DATE            DATE,
          @Ld_ModifiedMaxEnd_DATE                  DATE,
          @Lc_Msg_CODE                             CHAR(1) = '',
          @Lc_Category_CODE                        CHAR(2) = ' ',
          @Lc_Subject_CODE                         CHAR(5) = ' ',
          @Lc_TypeContact_CODE                     CHAR(3) = ' ',
          @Lc_MethodContact_CODE                   CHAR(2) = ' ',
          @Lc_SourceContact_CODE                   CHAR(2) = ' ',
          @Lc_TypeAssigned_CODE                    CHAR(1) = ' ',
          @Lc_WorkerAssigned_ID                    CHAR(30) = ' ',
          @Lc_RoleAssigned_ID                      CHAR(10) = ' ',
          @Ld_Received_DATE                        DATE = '12/31/9999',
          @Lc_CallBack_INDC                        CHAR(1) = ' ',
          @Lc_NotifySender_INDC                    CHAR(1) = ' ',
          @Ln_Office_IDNO                          NUMERIC(3) = 0,
          @Lc_OpenCasesCaseRelationship_CODE       CHAR(1) = ' ',
          @Ls_DescriptionNote_TEXT                 VARCHAR(4000),
          @Ls_WorkerSignedOn_IDNO                  VARCHAR,
          @Ls_AddReferral_TEXT                     VARCHAR(100) = ' ',
          @Lc_LetterWriter_NAME                    CHAR(30) = ' ',
          @Ln_Check_NUMB                           NUMERIC(19) = 0,
          @Ln_Check_AMNT                           NUMERIC(9, 2) = 0,
          @Ld_Check_DATE                           DATE = '12/31/9999',
          @Ld_Receipt_DATE                         DATE = '12/31/9999',
          @Ls_DisbursedTo_CODE                     VARCHAR(100) = ' ',
          @Ld_Recieved_DATE                        DATE,
          @Lc_CaseCategory_CODE                    CHAR(2);
  DECLARE @Ld_Start_DATE            DATE,
          @Ld_End_DATE              DATE,
          @Lc_TypeWelfare_CODE      CHAR(1),
          @Ln_Case_IDNO             NUMERIC(6),
          @Ln_CaseWelfare_IDNO      NUMERIC(10),
          @Ln_WelfareMemberMci_IDNO NUMERIC(10),
          @Lc_Reason_CODE           CHAR(5),
          @Li_LhsMhisMax_QNTY       INT = 0,
          @Li_RhsMhisMax_QNTY       INT = 0,
          @Ln_EventGlobalSeq_NUMB   NUMERIC(19),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19),
          @Ld_MinBeginLhs_DATE      DATE,
          @Ld_MinEndLhs_DATE        DATE,
          @Ld_CurEndLhs_DATE        DATE = NULL,
          @Ld_MaxEndElig_DATE       DATE,
          @Lc_RhsLastRecord_INDC    CHAR(1),
          @Ln_RhsProcess_QNTY       INT = 0,
          @Li_LhsProcess_QNTY       INT = 0,
          @Ld_GrantChange_DATE      DATE,
          @Ln_IvaCase_ID            NUMERIC(10),
          @Lc_ProcessLastRec_INDC   CHAR(1),
          @Ln_Diff_QNTY             INT = 0,
          @Li_Begin_QNTY            INT = 0,
          @Ln_FirstChangedRec_NUMB  INT = 0,
          @Ld_MinBeginLhsLsup_DATE  DATE,
          @Ld_MinBeginRhsLsup_DATE  DATE,
          @Ls_MhisLsupArray_TEXT    VARCHAR(4000),
          @Ln_MhisLsup_QNTY         INT = 0,
          @Ln_Count_QNTY            INT = 0,
          @Li_RowsAffected_NUMB     INT = 0,
          @Lc_RecordModified_INDC   CHAR = 'N',
          @Ls_ReasonModified_CODE   CHAR = 'N',
          @Ld_Run_DATE              DATE,
          @Ln_Topic_IDNO            NUMERIC(10);
  DECLARE @Lc_TypeWelfareLHS_CODE      CHAR(1),
          @Ln_CaseWelfareLHS_IDNO      NUMERIC(10),
          @Ln_WelfareMemberMciLHS_IDNO NUMERIC(10),
          @Ld_BeginLHS_DATE            DATE,
          @Ld_EndLHS_DATE              DATE,
          @Lc_ReasonLHS_CODE           CHAR(3);
  DECLARE @Lc_TypeWelfareRHS_CODE      CHAR(1),
          @Ln_CaseWelfareRHS_IDNO      NUMERIC(10),
          @Ln_WelfareMemberMciRHS_IDNO NUMERIC(10),
          @Ld_BeginRHS_DATE            DATE,
          @Ld_EndRHS_DATE              DATE,
          @Lc_ReasonRHS_CODE           CHAR(3);
  DECLARE @Lc_TypeWelfareBeginLHS_CODE      CHAR(1),
          @Ln_CaseWelfareBeginLHS_IDNO      NUMERIC(10),
          @Ln_WelfareMemberMciBeginLHS_IDNO NUMERIC(10),
          @Ld_BeginBeginLHS_DATE            DATE,
          @Ld_EndBeginLHS_DATE              DATE,
          @Lc_ReasonBeginLHS_CODE           CHAR(3);
  DECLARE @Li_i SMALLINT,
          @Li_j SMALLINT,
          @Li_k SMALLINT;

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ld_Run_DATE = ISNULL(@Ad_Run_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());

   -- CURRENT MHIS Data for the Case and Member comination  
   INSERT INTO @Lt_LhsMhisData_TAB
   SELECT MH.Start_DATE,
          MH.End_DATE,
          MH.TypeWelfare_CODE,
          MH.CaseWelfare_IDNO,
          MH.WelfareMemberMci_IDNO,
          MH.Reason_CODE
     FROM MHIS_Y1 MH
    WHERE MH.Case_IDNO = @An_Case_IDNO
      AND MH.MemberMci_IDNO = @An_MemberMci_IDNO
    ORDER BY Start_DATE;

   INSERT INTO @Lt_RhsMhisData_TAB
   SELECT nref.value('Start_DATE[1]', 'DATE') AS Start_DATE,
          nref.value('End_DATE[1]', 'DATE') AS End_DATE,
          nref.value('TypeWelfare_CODE[1]', 'CHAR(1)') AS TypeWelfare_CODE,
          nref.value('CaseWelfare_IDNO[1]', 'NUMERIC(10)') AS CaseWelfare_IDNO,
          nref.value('WelfareMemberMci_IDNO[1]', 'NUMERIC(10)') AS WelfareMemberMci_IDNO,
          nref.value('Reason_CODE[1]', 'CHAR(2)') AS Reason_CODE
     FROM @As_RhsMhisData_XML.nodes('//Record') AS R(nref)
    ORDER BY Start_DATE;

   SELECT @Li_LhsMhisMax_QNTY = ISNULL(MAX(OMH.Seq_IDNO), 0)
     FROM @Lt_LhsMhisData_TAB OMH;

   SELECT @Li_RhsMhisMax_QNTY = ISNULL(MAX(MMH.Seq_IDNO), 0)
     FROM @Lt_RhsMhisData_TAB MMH;

   SELECT @Ld_MinEndLhs_DATE = OMH.End_DATE
     FROM @Lt_LhsMhisData_TAB OMH
    WHERE OMH.Seq_IDNO = @Li_LhsMhisMax_QNTY;

   SELECT @Ld_MaxEndElig_DATE = MMH.End_DATE
     FROM @Lt_RhsMhisData_TAB MMH
    WHERE MMH.Seq_IDNO = @Li_RhsMhisMax_QNTY;

   SELECT @Ld_MinBeginLhsLsup_DATE = OMH.Start_DATE
     FROM @Lt_LhsMhisData_TAB OMH
    WHERE OMH.Seq_IDNO = 1;

   SELECT @Ld_MinBeginRhsLsup_DATE = MMH.Start_DATE
     FROM @Lt_RhsMhisData_TAB MMH
    WHERE MMH.Seq_IDNO = 1;

   SET @Ln_FirstChangedRec_NUMB = @Ln_Zero_NUMB;
   SET @Lc_RecordModified_INDC = @Lc_No_INDC;
   SET @Li_i = 1;

   -- Begin First change in DataSet identification  
   WHILE @Li_i <= @Li_RhsMhisMax_QNTY
    BEGIN
     -- All modified mhis records are new  
     IF(@Li_i > @Li_LhsMhisMax_QNTY
        AND (SELECT MMH.Start_DATE
               FROM @Lt_RhsMhisData_TAB MMH
              WHERE MMH.Seq_IDNO = @Li_i) IS NOT NULL)
      BEGIN
       SET @Ln_FirstChangedRec_NUMB =@Li_i;

       BREAK;
      END

     -- Check for change in Record  
     IF EXISTS (SELECT 1
                  FROM @Lt_LhsMhisData_TAB OMH
                       JOIN @Lt_RhsMhisData_TAB MMH
                        ON OMH.Seq_IDNO = MMH.Seq_IDNO
                 WHERE OMH.Seq_IDNO = @Li_i
                   AND (OMH.Start_DATE != MMH.Start_DATE
                         OR OMH.End_DATE != MMH.End_DATE
                         OR OMH.TypeWelfare_CODE != MMH.TypeWelfare_CODE
                         OR OMH.CaseWelfare_IDNO != MMH.CaseWelfare_IDNO
                         OR ISNULL(OMH.Reason_CODE, '') != ISNULL(MMH.Reason_CODE, '')))
      BEGIN
       SET @Ln_FirstChangedRec_NUMB = @Li_i;
       SET @Lc_RecordModified_INDC = @Lc_Yes_INDC;

       BREAK;
      END
     ELSE IF EXISTS (SELECT 1
                  FROM @Lt_LhsMhisData_TAB OMH
                       JOIN @Lt_RhsMhisData_TAB MMH
                        ON OMH.Seq_IDNO = MMH.Seq_IDNO
                 WHERE OMH.Seq_IDNO = @Li_i
                   AND OMH.Start_DATE = MMH.Start_DATE
                   AND OMH.End_DATE = MMH.End_DATE
                   AND OMH.TypeWelfare_CODE = MMH.TypeWelfare_CODE
                   AND OMH.CaseWelfare_IDNO = MMH.CaseWelfare_IDNO
                   AND OMH.WelfareMemberMci_IDNO = MMH.WelfareMemberMci_IDNO
                   AND ISNULL(OMH.Reason_CODE, '') != ISNULL(MMH.Reason_CODE, '')) -- Check only Reason code change  
      BEGIN
       SET @Ls_ReasonModified_CODE = @Lc_Yes_INDC;
      END

     SET @Li_i = @Li_i + 1;
    END -- END OF WHILE LOOP  

   -- End First change in DataSet identification  
   IF (@Lc_RecordModified_INDC = @Lc_No_INDC
       AND @Ls_ReasonModified_CODE = @Lc_Yes_INDC)
    BEGIN
     SET @Ls_Sql_TEXT = 'NO CHANGE IDENTIFIED';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON_MHIS$SP_CHANGE_LSUP';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL(CAST(@An_Case_IDNO AS CHAR(6)), '') + ' MemberMci_IDNO ' + ISNULL(CAST(@An_MemberMci_IDNO AS CHAR(10)), '') + ' LSUP ARRAY Count_QNTY ' + ISNULL(CAST(@Ln_MhisLsup_QNTY AS CHAR(10)), '');

   --BEGIN LSUP CHANGE   
   IF(@Ln_FirstChangedRec_NUMB > @Ln_Zero_NUMB)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';

     EXEC BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_CaseCategoryIsChanged5050_NUMB,
      @Ac_Process_ID              = @Lc_Process_ID,
      @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
      @Ac_Note_INDC               = 'N',
      @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,-- New Generated Global Event  
      @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

     IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE)
      BEGIN
       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'BATCH_COMMON_MHIS$SP_CHANGE_LSUP_FOR_MHIS';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL(CAST(@An_Case_IDNO AS CHAR(6)), '') + ' MemberMci_IDNO ' + ISNULL(CAST(@An_MemberMci_IDNO AS CHAR(10)), '');

     DECLARE @Lx_MhisChange_XML XML = NULL;

     SET @Lx_MhisChange_XML = (SELECT MMH.Start_DATE,
                                      MMH.End_DATE,
                                      MMH.TypeWelfare_CODE
                                 FROM @Lt_RhsMhisData_TAB MMH
                                WHERE MMH.Seq_IDNO >= @Ln_FirstChangedRec_NUMB
                                ORDER BY MMH.Seq_IDNO
                               FOR XML PATH('Record'), ELEMENTS);

     EXEC BATCH_COMMON_MHIS$SP_CHANGE_LSUP_FOR_MHIS
      @An_Case_IDNO             = @An_Case_IDNO,
      @An_MemberMci_IDNO        = @An_MemberMci_IDNO,
      @Ax_MhisChange_XML        = @Lx_MhisChange_XML,-- Modified Xml paassed  
      @Ad_LhsBeginEligible_DATE = @Ld_OriginalMinLsupBegin_DATE,
      @Ad_RhsBeginEligible_DATE = @Ld_MofifiedMinLsupBegin_DATE,
      @Ad_EndEligible_DATE      = @Ld_ModifiedMaxEnd_DATE,
      @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,--  Passing New Event ID  
      @Ad_Run_DATE              = @Ld_Run_DATE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   --END LSUP CHANGE   
   SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_ENTITY_MATRIX';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL(CAST(@An_Case_IDNO AS CHAR(6)), '') + ' MemberMci_IDNO ' + ISNULL(CAST(@An_MemberMci_IDNO AS CHAR(10)), '');

   EXECUTE BATCH_COMMON$SP_ENTITY_MATRIX
    @An_EventGlobalSeq_NUMB           = @Ln_EventGlobalSeq_NUMB,
    @An_EventFunctionalSeq_NUMB       = @Li_ParticipantTanfStatusChange2720_NUMB,
    @An_EntityCase_IDNO               = @An_Case_IDNO,
    @An_EntityMemberMci_IDNO          = @An_MemberMci_IDNO,
    @Ac_EntityObligation_ID           = '',
    @Ac_EntityReasonBackOut_CODE      ='',
    @Ac_EntityRefundReasonStatus_CODE ='',
    @Ac_ReverseRangeReceipt_DATE      ='',
    @Ac_Msg_CODE                      = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT         = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Li_Begin_QNTY = 1;
   SET @Ln_RhsProcess_QNTY = 1;
   SET @Li_i = 1;

   -- END WHILE LOOP I through all modified row (RHS)  
   WHILE @Li_i <= @Li_RhsMhisMax_QNTY
    BEGIN
     -- LAST RECORD IDENTIFICATION      
     SET @Lc_RhsLastRecord_INDC = 'N';

     IF (@Li_i = @Li_RhsMhisMax_QNTY)
      BEGIN
       SET @Lc_RhsLastRecord_INDC = 'Y';
      END

     SET @Ld_MinBeginLhs_DATE = NULL;

     SELECT @Ld_MinBeginLhs_DATE = OMH.Start_DATE
       FROM @Lt_LhsMhisData_TAB OMH
      WHERE OMH.Seq_IDNO = @Li_Begin_QNTY;

     -- BEGIN All left out record are new   
     IF (@Li_Begin_QNTY > @Li_LhsMhisMax_QNTY)
      BEGIN
       SET @Ld_MinBeginLhs_DATE = NULL;

       SELECT @Lc_TypeWelfareRHS_CODE = MMH.TypeWelfare_CODE,
              @Ln_CaseWelfareRHS_IDNO = MMH.CaseWelfare_IDNO,
              @Ln_WelfareMemberMciRHS_IDNO = MMH.WelfareMemberMci_IDNO,
              @Ld_BeginRHS_DATE = MMH.Start_DATE,
              @Ld_EndRHS_DATE = MMH.End_DATE,
              @Lc_ReasonRHS_CODE = MMH.Reason_CODE
         FROM @Lt_RhsMhisData_TAB MMH
        WHERE MMH.Seq_IDNO = @Li_i;

       SELECT @Ld_GrantChange_DATE = @Ld_BeginRHS_DATE;

       SET @Ls_Sql_TEXT = 'BATCH_COMMON_MHIS$SP_PROCESS_MHIS';
       SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL(CAST(@An_Case_IDNO AS CHAR(6)), '') + ' MemberMci_IDNO ' + ISNULL(CAST(@An_MemberMci_IDNO AS CHAR(10)), '');

       -- TODO : Please add some more SQL_DATA  
       EXECUTE BATCH_COMMON_MHIS$SP_UPDATE_MHIS_RECORD
        @An_MemberMci_IDNO        = @An_MemberMci_IDNO,
        @An_Case_IDNO             = @An_Case_IDNO,
        @Ac_TypeWelfare_CODE      = @Lc_TypeWelfareRHS_CODE,
        @An_CaseWelfare_IDNO      = @Ln_CaseWelfareRHS_IDNO,
        @An_WelfareMemberMci_IDNO = @Ln_WelfareMemberMciRHS_IDNO,
        @Ad_MinBeginElig_DATE     = @Ld_MinBeginLhs_DATE,
        @Ad_OldEnd_DATE           = @Ld_CurEndLhs_DATE,
        @Ad_Start_DATE            = @Ld_BeginRHS_DATE,
        @Ad_End_DATE              = @Ld_EndRHS_DATE,
        @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
        @Ac_Reason_CODE           = @Lc_ReasonRHS_CODE,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @Ac_SignedOnWorker_ID     = @Ac_SignedOnWorker_ID,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE)
        BEGIN
         RAISERROR(50001,16,1);
        END

       SELECT @Lc_TypeWelfareLHS_CODE = OMH.TypeWelfare_CODE,
              @Ln_CaseWelfareLHS_IDNO = OMH.CaseWelfare_IDNO,
              @Ln_WelfareMemberMciLHS_IDNO = OMH.WelfareMemberMci_IDNO,
              @Ld_BeginLHS_DATE = OMH.Start_DATE,
              @Ld_EndLHS_DATE = OMH.End_DATE
         FROM @Lt_LhsMhisData_TAB OMH
        WHERE OMH.Seq_IDNO = @Li_i;

       -- Proration of grant - Identify IVA Case ID  
       SET @Ln_IvaCase_ID = NULL;

       IF @Lc_TypeWelfareRHS_CODE = @Ls_WelfareTypeTanf_CODE
        BEGIN
         SET @Ln_IvaCase_ID = @Ln_CaseWelfareRHS_IDNO;
        END
       ELSE IF @Lc_TypeWelfareLHS_CODE = @Ls_WelfareTypeTanf_CODE
        BEGIN
         SET @Ln_IvaCase_ID = @Ln_CaseWelfareLHS_IDNO;
        END

       IF (@Ln_IvaCase_ID IS NOT NULL)
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON_MHIS$SP_POPULATE_WELF_TBL';
         SET @Ls_Sqldata_TEXT = ' CaseWelfare_IDNO ' + ISNULL(CAST(@Ln_IvaCase_ID AS CHAR(10)), '') + ' GRANT CHANGE ' + ISNULL(CAST(@Ld_GrantChange_DATE AS CHAR(10)), '')

         INSERT INTO @Lt_MhisWel_TAB
                     (Begin_DATE,
                      CaseWelfare_IDNO)
         SELECT @Ld_GrantChange_DATE,
                @Ln_IvaCase_ID
          WHERE NOT EXISTS(SELECT 1
                             FROM @Lt_MhisWel_TAB MW
                            WHERE MW.CaseWelfare_IDNO = @Ln_IvaCase_ID);
        END
      END -- END All left out record are new      
     SET @Li_LhsProcess_QNTY = 0;
     SET @Li_j = @Li_Begin_QNTY;

     -- BEGIN WHILE LOOP J through all existing row    
     WHILE(@Li_j <= @Li_LhsMhisMax_QNTY)
      BEGIN
       SET @Li_LhsProcess_QNTY = @Li_LhsProcess_QNTY + 1;

       -- Read to Begin Record to local variabale  
       SELECT @Lc_TypeWelfareBeginLHS_CODE = OMH.TypeWelfare_CODE,
              @Ln_CaseWelfareBeginLHS_IDNO = OMH.CaseWelfare_IDNO,
              @Ln_WelfareMemberMciBeginLHS_IDNO = OMH.WelfareMemberMci_IDNO,
              @Ld_BeginBeginLHS_DATE = OMH.Start_DATE,
              @Ld_EndBeginLHS_DATE = OMH.End_DATE
         FROM @Lt_LhsMhisData_TAB OMH
        WHERE OMH.Seq_IDNO = @Li_Begin_QNTY;

       -- Read to Rhs Current record into local Variable  
       SELECT @Lc_TypeWelfareRHS_CODE = MMH.TypeWelfare_CODE,
              @Ln_CaseWelfareRHS_IDNO = MMH.CaseWelfare_IDNO,
              @Ln_WelfareMemberMciRHS_IDNO = MMH.WelfareMemberMci_IDNO,
              @Ld_BeginRHS_DATE = MMH.Start_DATE,
              @Ld_EndRHS_DATE = MMH.End_DATE,
              @Lc_ReasonRHS_CODE = MMH.Reason_CODE
         FROM @Lt_RhsMhisData_TAB MMH
        WHERE MMH.Seq_IDNO = @Li_i;

       -- BEGIN ORIGINAL DATE RANGE AND MODIFIED RANGE NO CHENGE   
       IF (@Ld_BeginRHS_DATE = @Ld_BeginBeginLHS_DATE
           AND @Ld_EndRHS_DATE = @Ld_EndBeginLHS_DATE)
        BEGIN
         SET @Ld_GrantChange_DATE = @Ld_BeginRHS_DATE;

         -- BEGIN Minimum Original Begin Date is equal to Modified Begin Date  
         IF (@Ld_MinBeginLhs_DATE = @Ld_BeginRHS_DATE)
          BEGIN
           /*  First  making sure That First Record is Matching for beg and end date */
           IF (@Ln_CaseWelfareRHS_IDNO = @Ln_CaseWelfareBeginLHS_IDNO
               AND @Ln_WelfareMemberMciRHS_IDNO = @Ln_WelfareMemberMciBeginLHS_IDNO
               AND @Lc_TypeWelfareRHS_CODE = @Lc_TypeWelfareLHS_CODE)
            BEGIN
             /* Making Sure No Changes In the Record. No Need To Process */
             SET @Li_Begin_QNTY = @Li_Begin_QNTY + 1;

             BREAK; -- Break the J Loop  
            END

           SELECT @Ld_CurEndLhs_DATE = CASE
                                        WHEN @Ld_EndBeginLHS_DATE >= @Ld_EndRHS_DATE
                                         THEN @Ld_EndBeginLHS_DATE
                                        ELSE @Ld_EndRHS_DATE
                                       END;

           SET @Ls_Sql_TEXT = ' BATCH_COMMON_MHIS$SP_PROCESS_MHIS_1';
           SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL(CAST(@An_Case_IDNO AS CHAR(6)), '') + ' MemberMci_IDNO ' + ISNULL(CAST(@An_MemberMci_IDNO AS CHAR(10)), '') + ' WELFARE TYPE ' + ISNULL(@Lc_TypeWelfareRHS_CODE, '') + ' DATE_BEGIN ' + ISNULL(CAST(@Ld_BeginRHS_DATE AS CHAR(10)), '') + ' End_DATE ' + ISNULL(CAST(@Ld_EndRHS_DATE AS CHAR(10)), '');

           EXECUTE BATCH_COMMON_MHIS$SP_UPDATE_MHIS_RECORD
            @An_MemberMci_IDNO        = @An_MemberMci_IDNO,
            @An_Case_IDNO             = @An_Case_IDNO,
            @Ac_TypeWelfare_CODE      = @Lc_TypeWelfareRHS_CODE,
            @An_CaseWelfare_IDNO      = @Ln_CaseWelfareRHS_IDNO,
            @An_WelfareMemberMci_IDNO = @Ln_WelfareMemberMciRHS_IDNO,
            @Ad_MinBeginElig_DATE     = @Ld_MinBeginLhs_DATE,
            @Ad_OldEnd_DATE           = @Ld_CurEndLhs_DATE,
            @Ad_Start_DATE            = @Ld_BeginRHS_DATE,
            @Ad_End_DATE              = @Ld_EndRHS_DATE,
            @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,-- Current Event ID  
            @Ac_Reason_CODE           = @Lc_ReasonRHS_CODE,
            @Ad_Run_DATE              = @Ld_Run_DATE,
            @Ac_SignedOnWorker_ID     = @Ac_SignedOnWorker_ID,
            @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END

           SET @Ln_IvaCase_ID = NULL;

           IF @Lc_TypeWelfareRHS_CODE = @Ls_WelfareTypeTanf_CODE
            BEGIN
             SET @Ln_IvaCase_ID = @Ln_CaseWelfareRHS_IDNO;
            END
           ELSE IF @Lc_TypeWelfareLHS_CODE = @Ls_WelfareTypeTanf_CODE
            BEGIN
             SET @Ln_IvaCase_ID = @Ln_CaseWelfareLHS_IDNO;
            END

           IF (@Ln_IvaCase_ID IS NOT NULL)
            BEGIN
             SET @Ls_Sql_TEXT = 'BATCH_COMMON_MHIS$SP_POPULATE_WELF_TBL_1';
             SET @Ls_Sqldata_TEXT = ' CaseWelfare_IDNO ' + ISNULL(CAST(@Ln_IvaCase_ID AS CHAR(10)), '') + ' GRANT CHANGE ' + ISNULL(CAST(@Ld_GrantChange_DATE AS CHAR(10)), '')

             INSERT INTO @Lt_MhisWel_TAB
                         (Begin_DATE,
                          CaseWelfare_IDNO)
             SELECT @Ld_GrantChange_DATE,
                    @Ln_IvaCase_ID
              WHERE NOT EXISTS(SELECT 1
                                 FROM @Lt_MhisWel_TAB MW
                                WHERE MW.CaseWelfare_IDNO = @Ln_IvaCase_ID);
            END

           SET @Li_Begin_QNTY = @Li_Begin_QNTY + 1;

           BREAK; -- BREAK the J LOOP   
          END
         -- END Minimum original orginal date is equal to Modified Begin Date  
         ELSE
          -- ELSE BEGIN Minimum original orginal date is equal to Modified Begin Date  
          BEGIN
           SELECT @Ld_CurEndLhs_DATE = CASE
                                        WHEN @Ld_EndBeginLHS_DATE >= @Ld_EndRHS_DATE
                                         THEN @Ld_EndBeginLHS_DATE
                                        ELSE @Ld_EndRHS_DATE
                                       END;

           SET @Ls_Sql_TEXT = ' BATCH_COMMON_MHIS$SP_PROCESS_MHIS_2';
           SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL(CAST(@An_Case_IDNO AS CHAR(6)), '') + ' MemberMci_IDNO ' + ISNULL(CAST(@An_MemberMci_IDNO AS CHAR(10)), '') + ' WELFARE TYPE ' + ISNULL(@Lc_TypeWelfareRHS_CODE, '') + ' DATE_BEGIN ' + ISNULL(CAST(@Ld_BeginRHS_DATE AS CHAR(10)), '') + ' End_DATE ' + ISNULL(CAST(@Ld_EndRHS_DATE AS CHAR(10)), '')

           EXECUTE BATCH_COMMON_MHIS$SP_UPDATE_MHIS_RECORD
            @An_MemberMci_IDNO        = @An_MemberMci_IDNO,
            @An_Case_IDNO             = @An_Case_IDNO,
            @Ac_TypeWelfare_CODE      = @Lc_TypeWelfareRHS_CODE,
            @An_CaseWelfare_IDNO      = @Ln_CaseWelfareRHS_IDNO,
            @An_WelfareMemberMci_IDNO = @Ln_WelfareMemberMciRHS_IDNO,
            @Ad_MinBeginElig_DATE     = @Ld_MinBeginLhs_DATE,
            @Ad_OldEnd_DATE           = @Ld_CurEndLhs_DATE,
            @Ad_Start_DATE            = @Ld_BeginRHS_DATE,
            @Ad_End_DATE              = @Ld_EndRHS_DATE,
            @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,-- Current Event ID  
            @Ac_Reason_CODE           = @Lc_ReasonRHS_CODE,
            @Ad_Run_DATE              = @Ld_Run_DATE,
            @Ac_SignedOnWorker_ID     = @Ac_SignedOnWorker_ID,
            @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END

           -- Proration of Grant  
           SET @Ln_IvaCase_ID = NULL;

           IF @Lc_TypeWelfareRHS_CODE = @Ls_WelfareTypeTanf_CODE
            BEGIN
             SET @Ln_IvaCase_ID = @Ln_CaseWelfareRHS_IDNO;
            END
           ELSE IF @Lc_TypeWelfareLHS_CODE = @Ls_WelfareTypeTanf_CODE
            BEGIN
             SET @Ln_IvaCase_ID = @Ln_CaseWelfareLHS_IDNO;
            END

           IF (@Ln_IvaCase_ID IS NOT NULL)
            BEGIN
             SET @Ls_Sql_TEXT = 'BATCH_COMMON_MHIS$SP_POPULATE_WELF_TBL_2';
             SET @Ls_Sqldata_TEXT = ' CaseWelfare_IDNO ' + ISNULL(CAST(@Ln_IvaCase_ID AS CHAR(10)), '') + ' GRANT CHANGE ' + ISNULL(CAST(@Ld_GrantChange_DATE AS CHAR(10)), '');

             INSERT INTO @Lt_MhisWel_TAB
                         (Begin_DATE,
                          CaseWelfare_IDNO)
             SELECT @Ld_GrantChange_DATE,
                    @Ln_IvaCase_ID
              WHERE NOT EXISTS(SELECT 1
                                 FROM @Lt_MhisWel_TAB MW
                                WHERE MW.CaseWelfare_IDNO = @Ln_IvaCase_ID);
            END

           SET @Li_Begin_QNTY = @Li_Begin_QNTY + 1;

           BREAK; -- BREAK the J Loop  
          END
        END
       -- ELSE END Minimum original orginal date is equal to Modified Begin Date  
       ELSE -- ELSE BEGIN ORIGINAL DATE RANGE AND MODIFIED  RANGE NO CHENGE  
        BEGIN
         IF (@Ld_EndBeginLHS_DATE >= @Ld_BeginRHS_DATE
              OR @Lc_RhsLastRecord_INDC = 'Y')
          BEGIN
           IF (@Ld_BeginBeginLHS_DATE = @Ld_BeginRHS_DATE
                OR @Li_LhsProcess_QNTY = 1)
            BEGIN
             IF (@Ld_EndBeginLHS_DATE >= @Ld_EndRHS_DATE)
              BEGIN
               IF (@Ld_EndBeginLHS_DATE = @Ld_EndRHS_DATE
                   AND @Ld_BeginBeginLHS_DATE = @Ld_BeginRHS_DATE)
                BEGIN
                 SET @Ld_GrantChange_DATE = @Ld_BeginRHS_DATE;
                END
               ELSE IF @Ld_EndRHS_DATE = @Ld_High_DATE
                BEGIN
                 SET @Ld_GrantChange_DATE = @Ld_BeginRHS_DATE;
                END
               ELSE
                BEGIN
                 SET @Ld_GrantChange_DATE = @Ld_EndRHS_DATE;
                END

               SET @Ld_CurEndLhs_DATE = @Ld_EndBeginLHS_DATE;
              END
             ELSE
              BEGIN
               SET @Ld_CurEndLhs_DATE = @Ld_EndRHS_DATE; -- COMEHERE  
               SET @Ld_GrantChange_DATE = @Ld_EndBeginLHS_DATE;
              END
            END
           ELSE
            BEGIN
             /* PREVIOUS RECORD */
             DECLARE @Ld_PrevEndLHS_DATE DATE = NULL;

             SELECT @Ld_PrevEndLHS_DATE = PR.End_DATE
               FROM @Lt_LhsMhisData_TAB PR
              WHERE PR.Seq_IDNO = (@Li_Begin_QNTY - 1);

             IF @Ld_PrevEndLHS_DATE >= @Ld_EndRHS_DATE
              BEGIN
               SET @Ld_CurEndLhs_DATE = @Ld_PrevEndLHS_DATE;
               SET @Ld_GrantChange_DATE = @Ld_EndRHS_DATE;
              END
             ELSE
              BEGIN
               SET @Ld_CurEndLhs_DATE = @Ld_EndRHS_DATE;
               SET @Ld_GrantChange_DATE = @Ld_PrevEndLHS_DATE;
              END
            /* NEXT RECORD  */
            END

           SET @Ls_Sql_TEXT = ' BATCH_COMMON_MHIS$SP_PROCESS_MHIS_3';
           SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL(CAST(@An_Case_IDNO AS CHAR(6)), '') + ' MemberMci_IDNO ' + ISNULL(CAST(@An_MemberMci_IDNO AS CHAR(10)), '') + ' WELFARE TYPE ' + ISNULL(@Lc_TypeWelfareRHS_CODE, '') + ' DATE_BEGIN ' + ISNULL(CAST(@Ld_BeginRHS_DATE AS CHAR(10)), '') + ' End_DATE ' + ISNULL(CAST(@Ld_EndRHS_DATE AS CHAR(10)), '');

           EXECUTE BATCH_COMMON_MHIS$SP_UPDATE_MHIS_RECORD
            @An_MemberMci_IDNO        = @An_MemberMci_IDNO,
            @An_Case_IDNO             = @An_Case_IDNO,
            @Ac_TypeWelfare_CODE      = @Lc_TypeWelfareRHS_CODE,
            @An_CaseWelfare_IDNO      = @Ln_CaseWelfareRHS_IDNO,
            @An_WelfareMemberMci_IDNO = @Ln_WelfareMemberMciRHS_IDNO,
            @Ad_MinBeginElig_DATE     = @Ld_MinBeginLhs_DATE,
            @Ad_OldEnd_DATE           = @Ld_CurEndLhs_DATE,
            @Ad_Start_DATE            = @Ld_BeginRHS_DATE,
            @Ad_End_DATE              = @Ld_EndRHS_DATE,
            @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
            @Ac_Reason_CODE           = @Lc_ReasonRHS_CODE,
            @Ad_Run_DATE              = @Ld_Run_DATE,
            @Ac_SignedOnWorker_ID     = @Ac_SignedOnWorker_ID,
            @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END

           /* Proration of grant */
           SET @Ln_IvaCase_ID = NULL;

           IF @Lc_TypeWelfareRHS_CODE = @Ls_WelfareTypeTanf_CODE
            BEGIN
             SET @Ln_IvaCase_ID = @Ln_CaseWelfareRHS_IDNO;
            END
           ELSE IF @Lc_TypeWelfarelHS_CODE = @Ls_WelfareTypeTanf_CODE
            BEGIN
             SET @Ln_IvaCase_ID = @Ln_CaseWelfarelHS_IDNO;
            END

           IF @Ln_IvaCase_ID IS NOT NULL
            BEGIN -- BEGIN OF CASE ID NOT NULL  
             SET @Ls_Sql_TEXT = 'BATCH_COMMON_MHIS$SP_POPULATE_WELF_TBL_3';
             SET @Ls_Sqldata_TEXT = ' CaseWelfare_IDNO ' + ISNULL(CAST(@Ln_IvaCase_ID AS CHAR(10)), '') + ' GRANT CHANGE ' + ISNULL(CAST(@Ld_GrantChange_DATE AS CHAR(10)), '');

             INSERT INTO @Lt_MhisWel_TAB
                         (Begin_DATE,
                          CaseWelfare_IDNO)
             SELECT @Ld_GrantChange_DATE,
                    @Ln_IvaCase_ID
              WHERE NOT EXISTS(SELECT 1
                                 FROM @Lt_MhisWel_TAB MW
                                WHERE MW.CaseWelfare_IDNO = @Ln_IvaCase_ID);
            END -- END OF CASE ID NOT NULL  
           IF (@Li_LhsProcess_QNTY = 1)
            BEGIN
             SET @Li_Begin_QNTY = @Li_Begin_QNTY + 1;
            END

           BREAK; --Modified by ARun  
          END -- END OF BeginCountEndDATE >= RHS BEGIN DATE  
        END

       -- END ORIGINAL DATE RANGE AND MODIFIED RANGE NO CHENGE   
       SET @Li_Begin_QNTY = @Li_Begin_QNTY + 1;
      END

     -- BEGIN WHILE LOOP J through all existing row    
     SET @Li_i= @Li_i + 1;
    END

   -- END WHILE LOOP I through all modified row (RHS)  
   SET @Li_k = @Li_Begin_QNTY;

   WHILE (@Li_k <= @Li_LhsMhisMax_QNTY) -- BEGIN K LOOP  
    BEGIN
     IF (@Li_Begin_QNTY > @Li_RhsMhisMax_QNTY) -- BEGIN ALL MODIFIED ROWS COMPLTED (OLD RECORD DELETE)  
      BEGIN
       SET @Ls_Sql_TEXT = 'DELETE MHIS_Y1';
       SET @Ls_Sqldata_TEXT = ' EventGlobalEndSeq_NUMB ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS CHAR(19)), '') + ' MemberMci_IDNO ' + ISNULL(CAST(@An_MemberMci_IDNO AS CHAR(10)), '') + ' Case_IDNO ' + ISNULL(CAST(@An_Case_IDNO AS CHAR(6)), '') + ' DATE_BEGIN ' + ISNULL(CAST(@Ld_BeginLHS_DATE AS CHAR(10)), '');

       -- MOVE RECORD HISTORY      
       DELETE FROM MHIS_Y1
       OUTPUT Deleted.MemberMci_IDNO,
              Deleted.Case_IDNO,
              Deleted.Start_DATE,
              Deleted.End_DATE,
              Deleted.TypeWelfare_CODE,
              Deleted.CaseWelfare_IDNO,
              Deleted.WelfareMemberMci_IDNO,
              Deleted.CaseHead_INDC,
              Deleted.Reason_CODE,
              Deleted.EventGlobalBeginSeq_NUMB,
              @Ln_EventGlobalSeq_NUMB AS EventGlobalEndSeq_NUMB,
              Deleted.BeginValidity_DATE,
              @Ad_Run_DATE AS EndValidity_DATE
       INTO HMHIS_Y1
        WHERE Case_IDNO = @An_Case_IDNO
          AND MemberMci_IDNO = @An_MemberMci_IDNO
          AND Start_DATE = @Ld_BeginLHS_DATE
          AND EventGlobalBeginSeq_NUMB != @Ln_EventGlobalSeq_NUMB;

       SET @Li_RowsAffected_NUMB = @@ROWCOUNT;

       IF (@Lc_TypeWelfareBeginLHS_CODE = @Ls_WelfareTypeTanf_CODE) --BEGIN ORIGINAL TYPE IS TANF  
        BEGIN
         SET @Ln_IvaCase_ID = @Ln_CaseWelfareBeginLHS_IDNO;
         SET @Ld_GrantChange_DATE = @Ld_BeginBeginLHS_DATE;

         IF (@Ln_IvaCase_ID IS NOT NULL)
          BEGIN
           SET @Ls_Sql_TEXT = 'BATCH_COMMON_MHIS$SP_POPULATE_WELF_TBL_4';
           SET @Ls_Sqldata_TEXT = ' CaseWelfare_IDNO ' + ISNULL(CAST(@Ln_IvaCase_ID AS CHAR(10)), '') + ' GRANT CHANGE ' + ISNULL(CAST(@Ld_GrantChange_DATE AS CHAR(10)), '');

           INSERT INTO @Lt_MhisWel_TAB
                       (Begin_DATE,
                        CaseWelfare_IDNO)
           SELECT @Ld_GrantChange_DATE,
                  @Ln_IvaCase_ID
            WHERE NOT EXISTS(SELECT 1
                               FROM @Lt_MhisWel_TAB MW
                              WHERE MW.CaseWelfare_IDNO = @Ln_IvaCase_ID);
          END
        END --END ORIGINAL TYPE IS TANF  
      END -- END ALL MODIFIED ROWS COMPLTED (OLD RECORD DELETE)  

     SET @Li_Begin_QNTY = @Li_Begin_QNTY + 1;
     SET @Li_k = @Li_k + 1;
    END -- END K LOOP  

   IF @Ac_Job_ID <> 'DEB8114'
    BEGIN
     SET @Ln_Diff_QNTY = @Ln_Zero_NUMB;

     DECLARE @Li_MhisWelMax_QNTY INT = 0;

     SELECT @Li_MhisWelMax_QNTY = ISNULL(MAX(MW.Seq_IDNO), 0)
       FROM @Lt_MhisWel_TAB MW;

     SET @Li_i = 1;

     --BEGIN LOOP PRORATE GRANT   
     WHILE @Li_i <= @Li_MhisWelMax_QNTY
      BEGIN
       SET @Ln_Diff_QNTY = @Ln_Diff_QNTY + 1;
       SET @Lc_ProcessLastRec_INDC = @Lc_No_INDC;

       SELECT @Ld_Start_DATE = MW.Begin_DATE,
              @Ln_CaseWelfare_IDNO = MW.CaseWelfare_IDNO
         FROM @Lt_MhisWel_TAB MW
        WHERE @Li_i = MW.seq_IDNO;

       IF @Ln_Diff_QNTY = @Li_i
        BEGIN
         SET @Lc_ProcessLastRec_INDC = @Lc_Yes_INDC;
        END

       SET @Ls_Sql_TEXT = ' BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_MHIS ';
       SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO ' + ISNULL(CAST(@An_MemberMci_IDNO AS CHAR(10)), '') + ' Case_IDNO ' + ISNULL(CAST(@An_Case_IDNO AS CHAR(6)), '') + ' DATE_BEGIN ' + ISNULL(CAST(@Ld_Start_DATE AS CHAR(10)), '') + ' IVA CASE Seq_IDNO ' + ISNULL(CAST(@Ln_CaseWelfare_IDNO AS CHAR(10)), '');

       EXECUTE BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_MHIS
        @An_Case_IDNO             = @An_Case_IDNO,
        @An_MemberMci_IDNO        = @An_MemberMci_IDNO,
        @An_CaseWelfare_IDNO      = @Ln_CaseWelfare_IDNO,
        @Ad_Start_DATE            = @Ld_Start_DATE,
        @Ac_LastRec_INDC          = @Lc_ProcessLastRec_INDC,
        @Ac_SignedOnWorker_ID     = @Ac_SignedOnWorker_ID,
        @As_Screen_ID             = @Lc_Process_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE)
        BEGIN
         RAISERROR(50001,16,1);
        END

       SET @Li_i = @Li_i + 1;
      END
    END

   -- END LOOP PRORATE GRANT   
   SET @Ls_Sql_TEXT = 'CALLING BATCH_COMMON_MHIS$SP_UPDATE_CASE_CATEGORY';

   EXECUTE BATCH_COMMON_MHIS$SP_UPDATE_CASE_CATEGORY
    @An_Case_IDNO             = @An_Case_IDNO,
    @An_MemberMci_IDNO        = @An_MemberMci_IDNO,
    @As_WorkerSignedOn_IDNO   = @Ac_SignedOnWorker_ID,
    @Ac_Job_ID                = @Ac_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE)
    BEGIN
     RAISERROR(50001,16,1);
    END

   SELECT @Lc_TypeWelfareLHS_CODE = OMH.TypeWelfare_CODE
     FROM @Lt_LhsMhisData_TAB OMH
    WHERE OMH.Seq_IDNO = @Li_LhsMhisMax_QNTY;

   SELECT @Lc_TypeWelfareRHS_CODE = MH.TypeWelfare_CODE
     FROM @Lt_RhsMhisData_TAB MH
    WHERE MH.Seq_IDNO = @Li_RhsMhisMax_QNTY;

   IF (@Lc_TypeWelfareLHS_CODE <> @Lc_TypeWelfareRHS_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
     SET @Ls_Sqldata_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';

    EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT  
	 @Ac_Worker_ID                = @Ac_SignedOnWorker_ID,
	 @Ac_Process_ID               = @Lc_Process_ID,
	 @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
	 @Ac_Note_INDC                = 'N',
	 @An_EventFunctionalSeq_NUMB  = @Li_CaseCategoryIsChanged5050_NUMB,
	 @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
	 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
	 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_Sqldata_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';

       RAISERROR ( 50001,16,1);
      END

     --13736 - Assigning description note text to variable -START-
     SET @Ls_DescriptionNote_TEXT = 'MEMBER PROGRAM TYPE HAS BEEN CHANGED FROM ' + @Lc_TypeWelfareLHS_CODE + ' - ' + ISNULL (dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC (@Lc_TableMhis_ID , @Lc_TableSubPgty_ID, @Lc_TypeWelfareLHS_CODE), '') + ' TO ' + @Lc_TypeWelfareRHS_CODE + ' - ' + ISNULL (dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC (@Lc_TableMhis_ID, @Lc_TableSubPgty_ID, @Lc_TypeWelfareRHS_CODE), '');
     --13736 - Assigning description note text to variable -END-
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
     SET @Ls_Sqldata_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY' + CAST(@Ln_Case_IDNO AS CHAR(6));

     EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
      @An_Case_IDNO                = @An_Case_IDNO,
      @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
      @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
      @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorUMHIS_CODE,
      @Ac_Subsystem_CODE           = @Lc_SubsystemCM_CODE,
      @As_DescriptionNote_TEXT     = @Ls_DescriptionNote_TEXT,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
      @Ac_WorkerUpdate_ID          = @Ac_SignedOnWorker_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_Job_ID                   = @Lc_Process_ID,
      @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END;
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Ln_Error_NUMB AS INT = ERROR_NUMBER ();
   DECLARE @Ln_ErrorLine_NUMB AS INT = ERROR_LINE ();

   IF @Ln_Error_NUMB = 50001
    BEGIN
     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = @Ln_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END
   ELSE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = @Ln_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
