/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_INSERT_SCHEDULE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_COMMON$SP_INSERT_SCHEDULE
Programmer Name	:	IMP Team.
Description		:	It is used to insert the participating members for scheduling and  Genetic test related scheduling to add the GTST, 
                      it is done the Automatic updating for GTST
Frequency		:	
Developed On	:	04/04/2011
Called By		:	BATCH_COMMON$SP_UPDATE_MINOR_INSERT_SCHEDULE
Called On		:	BATCH_COMMON$SP_FLOW_SCHEDULE_GENETIC_INFO
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_INSERT_SCHEDULE]
 @An_Schedule_NUMB            NUMERIC(10),
 @An_Case_IDNO                NUMERIC(6),
 @An_OthpLocation_IDNO        NUMERIC(9),
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_WorkerDelegateTo_ID      CHAR(30),
 @Ac_TypeActivity_CODE        CHAR(1),
 @Ad_Schedule_DATE            DATE,
 @Ad_BeginSch_DTTM            DATETIME2,
 @Ad_EndSch_DTTM              DATETIME2,
 @Ac_ApptStatus_CODE          CHAR(2),
 @An_SchParent_NUMB           NUMERIC(10),
 @An_SchPrev_NUMB             NUMERIC(10),
 @Ac_SignedOnWorker_ID        CHAR(30)			= NULL,
 @Ac_WorkerUpdate_ID          CHAR(30)			= NULL,
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_TypeFamisProceeding_CODE CHAR(5),
 @Ac_ReasonAdjourn_CODE       CHAR(3),
 @As_Worker_NAME              VARCHAR(78),
 @Ac_ScheduleWorker_ID        CHAR(30),
 @As_ScheduleListMemberMci_ID VARCHAR(400),
 @Ac_SchedulingUnit_CODE      CHAR(2)			= ' ',
 @An_MajorIntSeq_NUMB         NUMERIC(5),
 @Ac_Msg_CODE                 CHAR(5)			OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000)		OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;
  SET QUOTED_IDENTIFIER ON;
  
  DECLARE @Lc_StatusSuccess_CODE				CHAR(1)			= 'S',
          @Lc_StatusFail_CODE					CHAR(1)			= 'F',
          @Lc_TypeActivityGenetic_CODE			CHAR(1)			= 'G',
          @Lc_TypeTestDnaTypingBuccalSwab_CODE	CHAR(1)			= 'S',
          @Lc_Delimiter_CODE					CHAR(1)			= ',',
          @Lc_Yes_INDC							CHAR(1)			= 'Y',
          @Lc_No_INDC							CHAR(1)			= 'N',
          @Lc_CaseRelationshipCp_CODE			CHAR(1)			= 'C',
          @Lc_Space_TEXT						CHAR(1)			= ' ',
          @Lc_TypeTest_CODE						CHAR(1)			= ' ',
          @Lc_TypeFamisProceedingGenetic_CODE	CHAR(1)			= 'B',
          @Lc_Screen_ID							CHAR(4)			= 'SPRO',
          @Lc_Participant_ID					CHAR(30)		= ' ',
          @Lc_Worker_ID							CHAR(30)		= ' ',
          @Ls_Procedure_NAME					VARCHAR(60)		= 'BATCH_COMMON$SP_INSERT_SCHEDULE';
  DECLARE @Li_CharIndex_NUMB					INT				= 0,					
		  @Ln_Error_NUMB						NUMERIC(10),
          @Ln_RowCount_QNTY						NUMERIC(10),
          @Ln_MemberMci_IDNO					NUMERIC(10)		= 0,
          @Ln_MemberMciCp_IDNO					NUMERIC(10)		= 0,
          @Ln_ErrorLine_NUMB					NUMERIC(11),
          @Lc_RecordLast_INDC					CHAR(1),
          @Ls_Sql_TEXT							VARCHAR(300),
          @Ls_MemberList_TEXT					VARCHAR(400),
          @Ls_Sqldata_TEXT						VARCHAR(3000),
          @Ls_ErrorMessage_TEXT					VARCHAR(4000),
          @Ld_Current_DTTM						DATETIME2		= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  BEGIN TRY
   SET @Ac_Msg_CODE ='';

   IF (LTRIM(RTRIM(@Ac_WorkerUpdate_ID)) IS NOT NULL)
      AND (LTRIM(RTRIM(@Ac_WorkerUpdate_ID)) != '')
    BEGIN
     SET @Ac_SignedonWorker_ID = @Ac_WorkerUpdate_ID;
    END
    
   SET @Ls_Sql_TEXT = 'INSERT INTO SWKS';
   SET @Ls_Sqldata_TEXT = 'Schedule_NUMB = ' + ISNULL(CAST(@An_Schedule_NUMB AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') 
							+ ', Worker_ID = ' + ISNULL(@Ac_ScheduleWorker_ID, '') + ', OthpLocation_IDNO = ' + ISNULL(CAST(@An_OthpLocation_IDNO AS VARCHAR), '') 
							+ ', ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Ac_ActivityMinor_CODE, '') 
							+ ', WorkerDelegateTo_ID = ' + ISNULL(@Ac_WorkerDelegateTo_ID, '') + ', TypeActivity_CODE = ' + ISNULL(@Ac_TypeActivity_CODE, '') + ', Schedule_DATE = ' 
							+ ISNULL(CAST(@Ad_Schedule_DATE AS VARCHAR), '') + ', BeginSch_DTTM = ' + ISNULL(CAST(@Ad_BeginSch_DTTM AS VARCHAR), '') + ', EndSch_DTTM = ' 
							+ ISNULL(CAST(@Ad_EndSch_DTTM AS VARCHAR), '') + ', ApptStatus_CODE = ' + ISNULL(@Ac_ApptStatus_CODE, '') + ', SchParent_NUMB = ' 
							+ ISNULL(CAST(@An_SchParent_NUMB AS VARCHAR), '') + ', SchPrev_NUMB = ' + ISNULL(CAST(@An_SchPrev_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_WorkerUpdate_ID, '') 
							+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS VARCHAR), '') + ', TypeFamisProceeding_CODE = ' 
							+ ISNULL(@Ac_TypeFamisProceeding_CODE, '') + ', ReasonAdjourn_CODE = ' + ISNULL(@Ac_ReasonAdjourn_CODE, '') + ', Worker_NAME = ' + ISNULL(@As_Worker_NAME, '') 
							+ ', SchedulingUnit_CODE = ' + ISNULL(@Ac_SchedulingUnit_CODE, '');

     INSERT SWKS_Y1
            (Schedule_NUMB,
             Case_IDNO,
             Worker_ID,
             MemberMci_IDNO,
             OthpLocation_IDNO,
             ActivityMajor_CODE,
             ActivityMinor_CODE,
             WorkerDelegateTo_ID,
             TypeActivity_CODE,
             Schedule_DATE,
             BeginSch_DTTM,
             EndSch_DTTM,
             ApptStatus_CODE,
             SchParent_NUMB,
             SchPrev_NUMB,
             WorkerUpdate_ID,
             BeginValidity_DATE,
             Update_DTTM,
             TransactionEventSeq_NUMB,
             TypeFamisProceeding_CODE,
             ReasonAdjourn_CODE,
             Worker_NAME,
             SchedulingUnit_CODE)
     SELECT  @An_Schedule_NUMB,--Schedule_NUMB
              @An_Case_IDNO,--Case_IDNO
              CASE WHEN p.Row_NUMB = 1
				THEN p.Participate_ID
				ELSE @Lc_Space_TEXT
              END ,--Worker_ID
              CASE WHEN p.Row_NUMB != 1
				THEN CAST(p.Participate_ID AS NUMERIC(10))
				ELSE 0
              END,--MemberMci_IDNO
              @An_OthpLocation_IDNO,--OthpLocation_IDNO
              @Ac_ActivityMajor_CODE,--ActivityMajor_CODE
              @Ac_ActivityMinor_CODE,--ActivityMinor_CODE
              @Ac_WorkerDelegateTo_ID,--WorkerDelegateTo_ID
              @Ac_TypeActivity_CODE,--TypeActivity_CODE
              @Ad_Schedule_DATE,--Schedule_DATE
              @Ad_BeginSch_DTTM,--BeginSch_DTTM
              @Ad_EndSch_DTTM,--EndSch_DTTM
              @Ac_ApptStatus_CODE,--ApptStatus_CODE
              @An_SchParent_NUMB,--SchParent_NUMB
              @An_SchPrev_NUMB,--SchPrev_NUMB
              @Ac_WorkerUpdate_ID,--WorkerUpdate_ID
              @Ld_Current_DTTM,--BeginValidity_DATE
              @Ld_Current_DTTM,--Update_DTTM
              @An_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
              @Ac_TypeFamisProceeding_CODE,--TypeFamisProceeding_CODE
              @Ac_ReasonAdjourn_CODE,--ReasonAdjourn_CODE
              @As_Worker_NAME,--Worker_NAME
              @Ac_SchedulingUnit_CODE --SchedulingUnit_CODE
		FROM
			(SELECT @Ac_ScheduleWorker_ID AS Participate_ID , 1 AS Row_NUMB
			 UNION
			 SELECT n.node.value('.', 'CHAR(30)') AS Participate_ID, ROW_NUMBER() OVER(ORDER BY n.node ASC)+1 AS Row_NUMB
				FROM (SELECT CAST('<node>'+REPLACE(@As_ScheduleListMemberMci_ID, ',', '</node><node>')+'</node>' AS XML)) as s(XMLCol)
				CROSS APPLY s.XMLCol.nodes('node') as n(node)) p
			

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT INTO SWKS FAILED';
       RAISERROR (50001,16,1);
      END


	IF (@Ac_TypeActivity_CODE = @Lc_TypeActivityGenetic_CODE
           OR @Ac_TypeFamisProceeding_CODE = @Lc_TypeFamisProceedingGenetic_CODE)
    BEGIN

	 SET @Ls_MemberList_TEXT = SUBSTRING(@As_ScheduleListMemberMci_ID, CHARINDEX(@Lc_Delimiter_CODE,@As_ScheduleListMemberMci_ID)+1,len(@As_ScheduleListMemberMci_ID));
	 
	 /* Setting genetic test type for Establishment activity */
    IF (@Ac_TypeFamisProceeding_CODE = @Lc_TypeFamisProceedingGenetic_CODE)
    BEGIN
     SET @Lc_TypeTest_CODE = @Lc_TypeTestDnaTypingBuccalSwab_CODE;
     SET @Ls_Sql_TEXT ='SELECT MemberMci_IDNO FROM CMEM_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_CaseRelationshipCp_CODE, '');
	 SELECT @Ln_MemberMciCp_IDNO = c.MemberMci_IDNO
       FROM CMEM_Y1 c
      WHERE c.Case_IDNO = @An_Case_IDNO
        AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE; 
    END
	 
   /*Inserting Member*/
   WHILE @Ls_MemberList_TEXT != ''
    BEGIN
	 SET @Li_CharIndex_NUMB = CHARINDEX(@Lc_Delimiter_CODE, @Ls_MemberList_TEXT);
	 
		-- Check whether delimiter char exists
		IF @Li_CharIndex_NUMB <> 0
		BEGIN
			SET @Lc_Participant_ID = SUBSTRING(@Ls_MemberList_TEXT, 0, @Li_CharIndex_NUMB);
			SET @Ls_MemberList_TEXT = SUBSTRING(@Ls_MemberList_TEXT, @Li_CharIndex_NUMB+1,LEN(@Ls_MemberList_TEXT));
			SET @Lc_RecordLast_INDC = @Lc_No_INDC;
		END
		ELSE
		BEGIN
			SET @Lc_Participant_ID = @Ls_MemberList_TEXT;
			SET @Ls_MemberList_TEXT = '';
			SET @Lc_RecordLast_INDC = @Lc_Yes_INDC;
		END

		SET @Ln_MemberMci_IDNO = CAST(@Lc_Participant_ID AS NUMERIC(10));

       /* CP genetic insert is not required for genetic insert made based proceeding type */
	   IF (@Ln_MemberMciCp_IDNO = @Ln_MemberMci_IDNO)
		BEGIN
		 CONTINUE;
		END

       /*The procedure BATCH_COMMON$SP_FLOW_SCHEDULE_GENETIC_INFO is used for inserting the records in GTST_Y1 table through SPRO and GTST screen. Apart from 
         inserting the record this batch will do the following process  */
       SET @Ls_Sql_TEXT='BATCH_COMMON$SP_FLOW_SCHEDULE_GENETIC_INFO';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@An_Schedule_NUMB AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Test_DATE = ' + ISNULL(CAST(@Ad_Schedule_DATE AS VARCHAR), '') + ', OthpLocation_IDNO = ' + ISNULL(CAST(@An_OthpLocation_IDNO AS VARCHAR), '') + ', SignedOnWorker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID, '') + ', TypeTest_CODE = ' + ISNULL(@Lc_TypeTest_CODE, '') + ', LastRowIndc_CODE = ' + ISNULL(@Lc_RecordLast_INDC, '') + ', Screen_ID = ' + ISNULL(@Lc_Screen_ID, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@An_MajorIntSeq_NUMB AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_FLOW_SCHEDULE_GENETIC_INFO
        @An_Case_IDNO                = @An_Case_IDNO,
        @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
        @An_Schedule_NUMB            = @An_Schedule_NUMB,
        @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
        @Ad_Test_DATE                = @Ad_Schedule_DATE,
        @An_Test_AMNT                = 0,
        @An_OthpLocation_IDNO        = @An_OthpLocation_IDNO,
        @As_PaidBy_NAME              = '',
        @Ac_SignedOnWorker_ID        = @Ac_SignedOnWorker_ID,
        @As_Location_NAME            = '',
        @Ac_TypeTest_CODE            = @Lc_TypeTest_CODE,
        @Ad_ResultsReceived_DATE     = '',
        @Ac_TestResult_CODE          = '',
        @An_Probability_PCT          = 0,
        @Ac_RecordLast_INDC          = @Lc_RecordLast_INDC,
        @Ac_Screen_ID                = @Lc_Screen_ID,
        @An_MajorIntSeq_NUMB         = @An_MajorIntSeq_NUMB,
        @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END
     
    END
  
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFail_CODE;
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
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
