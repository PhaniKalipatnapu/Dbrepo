/****** Object:  StoredProcedure [dbo].[BATCH_ENF_ELFC$SP_CLOSE_REMEDY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_ELFC$SP_CLOSE_REMEDY
Programmer Name		: IMP Team
Description			: This procedure closes the remedy.	
Frequency			: 
Developed On		: 04/08/2011
Called BY			: BATCH_ENF_ELFC$SP_PROCESS_ELFC
Called On	        : 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_ELFC$SP_CLOSE_REMEDY]
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC(2),
 @An_MemberMci_IDNO           NUMERIC(10),
 @An_OthpSource_IDNO          NUMERIC(10),
 @Ac_TypeReference_CODE       CHAR(5)		= ' ',
 @Ac_Reference_ID             CHAR(30)		= ' ',
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_ReasonStatus_CODE        CHAR(2),
 @Ac_Subsystem_CODE           CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ad_Run_DATE                 DATE,
 @Ac_Msg_CODE                 CHAR(5)		OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
BEGIN    
  SET NOCOUNT ON; 
  DECLARE @Li_Zero_NUMB							INT			= 0,
          @Lc_Space_TEXT						CHAR(1)		= ' ',
          @Lc_CaseRelationshipNcp_CODE			CHAR(1)		= 'A',
          @Lc_CaseRelationshipPf_CODE			CHAR(1)		= 'P',
          @Lc_StatusFailed_CODE					CHAR(1)		= 'F',
          @Lc_NotifySenderNo_INDC				CHAR(1)		= 'N',
          @Lc_StatusSuccess_CODE				CHAR(1)		= 'S',
          @Lc_IwnStatusPending_CODE				CHAR(1)		= 'P',
          @Lc_IwnStatusActive_CODE				CHAR(1)		= 'A',
          @Lc_IwnStatusTerminated_CODE			CHAR(1)		= 'T',
          @Lc_ReasonStatusSi_CODE				CHAR(2)		= 'SI',
          @Lc_ReasonStatusSy_CODE				CHAR(2)		= 'SY',
          @Lc_TypeChangeEe_CODE					CHAR(2)		= 'EE',
          @Lc_TypeChangeEt_CODE					CHAR(2)		= 'ET',
          @Lc_TypeChangeOt_CODE					CHAR(2)		= 'OT',
          @Lc_TypeChangeNs_CODE					CHAR(2)		= 'NS',
          @Lc_TypeChangeSt_CODE					CHAR(2)		= 'ST',
          @Lc_TypeChangeLc_CODE					CHAR(2)		= 'CR',
          @Lc_TypeChangeDe_CODE					CHAR(2)		= 'DE',     
          @Lc_ReasonStatusBc_CODE				CHAR(2)		= 'BC',
          @Lc_StatusConfirmedgood_CODE			CHAR(2)		= 'CG',
          @Lc_StatusStart_CODE					CHAR(4)		= 'STRT',
          @Lc_StatusComplete_CODE				CHAR(4)		= 'COMP',
          @Lc_ActivityMajorImiw_CODE			CHAR(4)		= 'IMIW',
          @Lc_ActivityMajorNmsn_CODE			CHAR(4)		= 'NMSN',
          @Lc_BatchRunUser_TEXT					CHAR(5)		= 'BATCH',
          @Lc_ActivityMinorMcmoi_CODE			CHAR(5)		= 'MCMOI',
          @Lc_ActivityMinorMpcoa_CODE			CHAR(5)		= 'MPCOA',
          @Lc_ActivityMinorRmdcy_CODE			CHAR(5)		= 'RMDCY',
          @Ls_Routine_TEXT						VARCHAR(75) = 'BATCH_ENF_ELFC$BATCH_ENF_ELFC$SP_CLOSE_REMEDY',
          @Ld_Low_DATE                  		DATE 		= '01/01/0001',
          @Ld_High_DATE                 		DATE 		= '12/31/9999';
  
  DECLARE @Ln_Record_QNTY						NUMERIC(3),
          @Ln_MajorIntSeq_NUMB					NUMERIC(5),
          @Ln_MinorIntSeq_NUMB					NUMERIC(5),
          @Ln_Forum_IDNO						NUMERIC(10),
          @Ln_Topic_IDNO						NUMERIC(10),
          @Ln_Error_NUMB						NUMERIC(10)		= 0,
          @Ln_ErrorLine_NUMB					NUMERIC(10)		= 0,
          @Ln_RowCount_QNTY						NUMERIC(10),
          @Ln_TransactionEventSeq_NUMB			NUMERIC(19),
          @Lc_ReasonStatus_CODE					CHAR(2)			= 'SY',
          @Ls_Notes_TEXT						VARCHAR(100)	= '',
          @Ls_Sql_TEXT							VARCHAR(100),
          @Ls_Sqldata_TEXT						VARCHAR(1000),
          @Ls_DescriptionError_TEXT				VARCHAR(4000),
          @Ld_Current_DTTM						DATETIME		= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_Space_TEXT;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ln_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
   SET @Ls_Sql_TEXT = 'ELFC0132 :  SELECT DMJR_Y1 - CHECK REMEDY EXISTS IN STRT Status_CODE';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   SELECT @Ln_Record_QNTY = COUNT(1)
     FROM DMJR_Y1 j
    WHERE j.Case_IDNO = @An_Case_IDNO
      AND j.MemberMci_IDNO = @An_MemberMci_IDNO
      AND j.OthpSource_IDNO = @An_OthpSource_IDNO
      AND j.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
      AND j.TypeReference_CODE = (SELECT CASE
                                          WHEN @Ac_TypeReference_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)
                                               AND @Ac_ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE,
                                                                                  @Lc_ActivityMajorNmsn_CODE)
                                           THEN j.TypeReference_CODE
                                          ELSE @Ac_TypeReference_CODE
                                         END AS TypeReference_CODE)
      AND j.Reference_ID = @Ac_Reference_ID
      AND j.Status_CODE = @Lc_StatusStart_CODE
      AND EXISTS (SELECT 1 
                    FROM DMNR_Y1 n
                   WHERE n.Case_IDNO = j.Case_IDNO
                     AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                     AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                     AND n.Status_CODE = @Lc_StatusStart_CODE);

   /* Record Count = 0 can occur, since the same TypeChange value is used for more than one remedy,
   there are more than one remedy listed for this TypeChange and which remedies are in STRT status
   alone should be closed, if not in STRT status should not perform anything */
   IF @Ln_Record_QNTY = 0
   BEGIN
		SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
		RETURN;
   END

   IF @Ac_ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE
    BEGIN
		 SELECT @Ln_Record_QNTY = COUNT(1)
		   FROM DMJR_Y1  j
		  WHERE j.Case_IDNO = @An_Case_IDNO
			AND j.MemberMci_IDNO = @An_MemberMci_IDNO
			AND j.OthpSource_IDNO = @An_OthpSource_IDNO
			AND j.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
			AND j.TypeReference_CODE = @Ac_TypeReference_CODE
			AND j.Reference_ID = @Ac_Reference_ID
			AND j.Status_CODE = @Lc_StatusStart_CODE
			AND EXISTS (SELECT 1 
						  FROM DMNR_Y1 n
						 WHERE n.Case_IDNO = j.Case_IDNO
						   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
						   AND n.ActivityMinor_CODE = @Lc_ActivityMinorMpcoa_CODE
						   AND n.Status_CODE = @Lc_StatusStart_CODE);

		 IF (@Ln_Record_QNTY >= 1
			AND @Ac_ReasonStatus_CODE = @Lc_TypeChangeOt_CODE)
		 BEGIN
			SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
			RETURN;
		 END
		 ELSE IF (@Ln_Record_QNTY > 0
			AND @Ac_ReasonStatus_CODE = @Lc_TypeChangeEt_CODE)
		 BEGIN
			SET @Lc_ReasonStatus_CODE = @Lc_ReasonStatusSy_CODE;
		 END
		 ELSE IF (@Ln_Record_QNTY > 0
			AND @Ac_ReasonStatus_CODE = @Lc_TypeChangeEe_CODE)
		 BEGIN
			SET @Lc_ReasonStatus_CODE = @Lc_ReasonStatusSi_CODE;
		 END
   END
   ELSE IF (@Ac_ActivityMajor_CODE = @Lc_ActivityMajorNmsn_CODE
      AND @Ac_ReasonStatus_CODE = @Lc_TypeChangeEe_CODE)
   BEGIN
		SELECT @Ln_Record_QNTY = COUNT(1)
		  FROM DMJR_Y1 j
		 WHERE j.Case_IDNO = @An_Case_IDNO
		   AND j.MemberMci_IDNO = @An_MemberMci_IDNO
		   AND j.OthpSource_IDNO = @An_OthpSource_IDNO
		   AND j.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
		   AND j.TypeReference_CODE = @Ac_TypeReference_CODE
		   AND j.Reference_ID = @Ac_Reference_ID
		   AND j.Status_CODE = @Lc_StatusStart_CODE
		   AND EXISTS (SELECT 1  
						  FROM DMNR_Y1 n
						 WHERE n.Case_IDNO = j.Case_IDNO
						   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
						   AND n.ActivityMinor_CODE = @Lc_ActivityMinorMcmoi_CODE
						   AND n.Status_CODE = @Lc_StatusStart_CODE);

		IF @Ln_Record_QNTY >= 1
		BEGIN
			SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
			RETURN;
		END
   END

   SET @Ls_Sql_TEXT = 'ELFC0133 :  SELECT NEXT SEQUENCE VALUE FOR Topic_IDNO ';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   INSERT INTO ITOPC_Y1
                (Entered_DATE)
        VALUES (@Ld_Current_DTTM  --Entered_DATE
                );
                
   SET @Ln_Topic_IDNO = @@IDENTITY;               
   SET @Ls_Sql_TEXT = 'ELFC0134 :  SELECT FORUM_ID, MajorIntSeq_NUMB, MinorIntSeq_NUMB FROM DMJR_Y1 AND DMNR_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS NVARCHAR(MAX)), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@An_OthpSource_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStart_CODE, '');

   SELECT @Ln_Forum_IDNO = j.Forum_IDNO,
          @Ln_MajorIntSeq_NUMB = j.MajorIntSeq_NUMB,
          @Ln_MinorIntSeq_NUMB = n.MinorIntSeq_NUMB
     FROM DMJR_Y1 j,
          DMNR_Y1 n
    WHERE j.Case_IDNO = @An_Case_IDNO
      AND j.MemberMci_IDNO = @An_MemberMci_IDNO
      AND j.OthpSource_IDNO = @An_OthpSource_IDNO
      AND j.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
      /* If the same source has more than one reference, if the code did not check with the input reference
      then too many rows exception will be raised, so the below condition has been added */
      AND j.Reference_ID = @Ac_Reference_ID
      AND j.Status_CODE = @Lc_StatusStart_CODE
      AND j.Case_IDNO = n.Case_IDNO
      AND j.OrderSeq_NUMB = n.OrderSeq_NUMB
      AND j.MajorIntSeq_NUMB = n.MajorIntSeq_NUMB
      AND n.Status_CODE = @Lc_StatusStart_CODE;

   SET @Ls_Sql_TEXT = 'ELFC0135 :  INSERT HDMNR_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS NVARCHAR(MAX)), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStart_CODE, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS NVARCHAR(MAX)), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS NVARCHAR(MAX)), '');

   --Updating the current In-Progress Activity to insert Next Activity
   INSERT HDMNR_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           MajorIntSeq_NUMB,
           MinorIntSeq_NUMB,
           MemberMci_IDNO,
           ActivityMinor_CODE,
           ActivityMinorNext_CODE,
           Entered_DATE,
           Due_DATE,
           Status_DATE,
           Status_CODE,
           ReasonStatus_CODE,
           Schedule_NUMB,
           Forum_IDNO,
           Topic_IDNO,
           TotalReplies_QNTY,
           TotalViews_QNTY,
           PostLastPoster_IDNO,
           UserLastPoster_ID,
           LastPost_DTTM,
           AlertPrior_DATE,
           BeginValidity_DATE,
           EndValidity_DATE,
           WorkerUpdate_ID,
           Update_DTTM,
           TransactionEventSeq_NUMB,
           WorkerDelegate_ID,
           ActivityMajor_CODE,
           Subsystem_CODE)
   SELECT n.Case_IDNO,
          n.OrderSeq_NUMB,
          n.MajorIntSeq_NUMB,
          n.MinorIntSeq_NUMB,
          n.MemberMci_IDNO,
          n.ActivityMinor_CODE,
          n.ActivityMinorNext_CODE,
          n.Entered_DATE,
          n.Due_DATE,
          n.Status_DATE,
          n.Status_CODE,
          n.ReasonStatus_CODE,
          n.Schedule_NUMB,
          n.Forum_IDNO,
          n.Topic_IDNO,
          n.TotalReplies_QNTY,
          n.TotalViews_QNTY,
          n.PostLastPoster_IDNO,
          n.UserLastPoster_ID,
          n.LastPost_DTTM,
          n.AlertPrior_DATE,
          n.BeginValidity_DATE,
          @Ad_Run_DATE AS EndValidity_DATE,
          n.WorkerUpdate_ID,
          n.Update_DTTM,
          n.TransactionEventSeq_NUMB,
          n.WorkerDelegate_ID,
          n.ActivityMajor_CODE,
          n.Subsystem_CODE
     FROM DMNR_Y1 n
    WHERE n.Case_IDNO = @An_Case_IDNO
      AND n.Status_CODE = @Lc_StatusStart_CODE
      AND n.MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB
      AND n.MinorIntSeq_NUMB = @Ln_MinorIntSeq_NUMB;
   
   SET @Ln_RowCount_QNTY  = @@ROWCOUNT;
   
   IF @Ln_RowCount_QNTY  = 0
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'HDMNR_Y1 INSERT FAILED';
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'ELFC0136 : UPDATE DMNR_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStart_CODE, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS NVARCHAR(MAX)), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS NVARCHAR(MAX)), '');

   UPDATE DMNR_Y1
      SET Status_CODE = @Lc_StatusComplete_CODE,
          Status_DATE = @Ad_Run_DATE,
          ActivityMinorNext_CODE = @Lc_ActivityMinorRmdcy_CODE,
          ReasonStatus_CODE = @Lc_ReasonStatus_CODE,
          BeginValidity_DATE = @Ad_Run_DATE,
          WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
          Update_DTTM = @Ld_Current_DTTM,
          TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
    WHERE Case_IDNO = @An_Case_IDNO
      AND Status_CODE = @Lc_StatusStart_CODE
      AND MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB
      AND MinorIntSeq_NUMB = @Ln_MinorIntSeq_NUMB;
      
    SET @Ln_RowCount_QNTY = @@ROWCOUNT;
    
   IF @Ln_RowCount_QNTY  = 0
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'DMNR_Y1 UPDATE FAILED';
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'ELFC0137 :  GET NEXT MinorIntSeq_NUMB FROM UDMNR_V1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS NVARCHAR(MAX)), '');

   SELECT @Ln_MinorIntSeq_NUMB = ISNULL(MAX(MinorIntSeq_NUMB), 0) + 1
     FROM UDMNR_V1 u
    WHERE Case_IDNO = @An_Case_IDNO
      AND MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB;

   SET @Ls_Sql_TEXT = 'ELFC0138 : INSERT DMNR_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS NVARCHAR(MAX)), '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS NVARCHAR(MAX)), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS NVARCHAR(MAX)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS NVARCHAR(MAX)), '');

   --Inserting the Next Activity
   INSERT DMNR_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           MajorIntSeq_NUMB,
           MinorIntSeq_NUMB,
           MemberMci_IDNO,
           ActivityMinor_CODE,
           ActivityMinorNext_CODE,
           Entered_DATE,
           Due_DATE,
           Status_DATE,
           Status_CODE,
           ReasonStatus_CODE,
           Schedule_NUMB,
           Forum_IDNO,
           Topic_IDNO,
           TotalReplies_QNTY,
           TotalViews_QNTY,
           PostLastPoster_IDNO,
           UserLastPoster_ID,
           LastPost_DTTM,
           AlertPrior_DATE,
           BeginValidity_DATE,
           WorkerUpdate_ID,
           Update_DTTM,
           TransactionEventSeq_NUMB,
           WorkerDelegate_ID, 
           Subsystem_CODE,
           ActivityMajor_CODE)
   VALUES ( @An_Case_IDNO,                 --Case_IDNO                
            @An_OrderSeq_NUMB,             --OrderSeq_NUMB            
            @Ln_MajorIntSeq_NUMB,          --MajorIntSeq_NUMB         
            @Ln_MinorIntSeq_NUMB,          --MinorIntSeq_NUMB         
            @An_MemberMci_IDNO,            --MemberMci_IDNO           
            @Lc_ActivityMinorRmdcy_CODE,   --ActivityMinor_CODE       
            @Lc_Space_TEXT,                --ActivityMinorNext_CODE   
            @Ad_Run_DATE,                  --Entered_DATE             
            @Ad_Run_DATE,                  --Due_DATE                 
            @Ad_Run_DATE,                  --Status_DATE              
            @Lc_StatusComplete_CODE,	   --Status_CODE              
            @Lc_ReasonStatusSy_CODE,       --ReasonStatus_CODE        
            @Li_Zero_NUMB,                 --Schedule_NUMB            
            @Ln_Forum_IDNO,                --Forum_IDNO               
            @Ln_Topic_IDNO,                --Topic_IDNO               
            @Li_Zero_NUMB,                 --TotalReplies_QNTY        
            @Li_Zero_NUMB,                 --TotalViews_QNTY          
            @Li_Zero_NUMB,                 --PostLastPoster_IDNO      
            @Lc_BatchRunUser_TEXT,         --UserLastPoster_ID        
            @Ld_Current_DTTM,              --LastPost_DTTM            
            @Ad_Run_DATE,                  --AlertPrior_DATE          
            @Ad_Run_DATE,                  --BeginValidity_DATE       
            @Lc_BatchRunUser_TEXT,         --WorkerUpdate_ID          
            @Ld_Current_DTTM,              --Update_DTTM              
            @Ln_TransactionEventSeq_NUMB,  --TransactionEventSeq_NUMB 
            @Lc_Space_TEXT,                --WorkerDelegate_ID        
            @Ac_Subsystem_CODE,            --Subsystem_CODE           
            @Ac_ActivityMajor_CODE);       --ActivityMajor_CODE    
               
   SET @Ln_RowCount_QNTY = @@ROWCOUNT;
   
   IF @Ln_RowCount_QNTY  = 0
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'DMNR_Y1 INSERT FAILED';
     RAISERROR(50001,16,1);
    END

   IF @Ac_ReasonStatus_CODE = @Lc_TypeChangeEe_CODE
   BEGIN
    SET @Ls_Notes_TEXT = 'SOI End-Dated';
   END
   IF @Ac_ReasonStatus_CODE = @Lc_TypeChangeEt_CODE
   BEGIN
    SET @Ls_Notes_TEXT = 'Employer no longer accepts eIWO';
   END
   ELSE IF @Ac_ReasonStatus_CODE = @Lc_TypeChangeOt_CODE
   BEGIN
    SET @Ls_Notes_TEXT = 'Obligation is terminated and no Arrears for the case';
    END
   ELSE IF @Ac_ReasonStatus_CODE = @Lc_TypeChangeNs_CODE
   BEGIN
    SET @Ls_Notes_TEXT = 'Dependents are not eligible for SOI sponsored insurance';
    END
   ELSE IF @Ac_ReasonStatus_CODE = @Lc_TypeChangeSt_CODE
   BEGIN
    SET @Ls_Notes_TEXT = 'Order Terminated';
    END
   ELSE IF @Ac_ReasonStatus_CODE = @Lc_TypeChangeLc_CODE
   BEGIN
    SET @Ls_Notes_TEXT = 'Last child removed from the order';
    END
   ELSE IF @Ac_ReasonStatus_CODE = @Lc_TypeChangeDe_CODE
   BEGIN
    SET @Ls_Notes_TEXT = 'All the dependents are enrolled in the insurance provided by the ordered party ' + 'or an associate of the ordered party';
    END
  
   IF @Ls_Notes_TEXT != ''
   BEGIN
	   SET @Ls_Sql_TEXT = 'ELFC0139 : INSERT_VNOTE';
	   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Topic_IDNO = ' + ISNULL(CAST(@Ln_Topic_IDNO AS NVARCHAR(MAX)), '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorRmdcy_CODE, '');

	   INSERT NOTE_Y1
			  (Case_IDNO,
			   Topic_IDNO,
			   Post_IDNO,
			   MajorIntSeq_NUMB,
			   MinorIntSeq_NUMB,
			   Office_IDNO,
			   Category_CODE,
			   Subject_CODE,
			   CallBack_INDC,
			   NotifySender_INDC,
			   TypeContact_CODE,
			   SourceContact_CODE,
			   MethodContact_CODE,
			   Status_CODE,
			   TypeAssigned_CODE,
			   WorkerAssigned_ID,
			   RoleAssigned_ID,
			   WorkerCreated_ID,
			   Start_DATE,
			   Due_DATE,
			   Action_DATE,
			   Received_DATE,
			   OpenCases_CODE,
			   DescriptionNote_TEXT,
			   BeginValidity_DATE,
			   EndValidity_DATE,
			   WorkerUpdate_ID,
			   TransactionEventSeq_NUMB,
			   EventGlobalSeq_NUMB,
			   Update_DTTM,
			   TotalReplies_QNTY,
			   TotalViews_QNTY)
	   VALUES ( @An_Case_IDNO,                --Case_IDNO               
				@Ln_Topic_IDNO,               --Topic_IDNO              
				1,                            --Post_IDNO               
				@Ln_MajorIntSeq_NUMB,         --MajorIntSeq_NUMB        
				@Ln_MinorIntSeq_NUMB,         --MinorIntSeq_NUMB        
				@Li_Zero_NUMB,                --Office_IDNO             
				@Lc_Space_TEXT,               --Category_CODE           
				@Lc_ActivityMinorRmdcy_CODE,  --Subject_CODE            
				@Lc_Space_TEXT,               --CallBack_INDC           
				@Lc_NotifySenderNo_INDC,               --NotifySender_INDC       
				@Lc_Space_TEXT,               --TypeContact_CODE        
				@Lc_Space_TEXT,               --SourceContact_CODE      
				@Lc_Space_TEXT,               --MethodContact_CODE      
				@Lc_Space_TEXT,               --Status_CODE             
				@Lc_Space_TEXT,               --TypeAssigned_CODE       
				@Lc_Space_TEXT,               --WorkerAssigned_ID       
				@Lc_Space_TEXT,               --RoleAssigned_ID         
				@Lc_BatchRunUser_TEXT,        --WorkerCreated_ID        
				@Ld_Low_DATE,             --Start_DATE              
				@Ld_Low_DATE,             --Due_DATE                
				@Ld_High_DATE,            --Action_DATE             
				@Ld_High_DATE,            --Received_DATE           
				@Lc_Space_TEXT,               --OpenCases_CODE          
				@Ls_Notes_TEXT,               --DescriptionNote_TEXT    
				@Ad_Run_DATE,                 --BeginValidity_DATE      
				@Ld_High_DATE,            --EndValidity_DATE        
				@Lc_BatchRunUser_TEXT,        --WorkerUpdate_ID         
				@Ln_TransactionEventSeq_NUMB, --TransactionEventSeq_NUMB
				@Li_Zero_NUMB,                --EventGlobalSeq_NUMB     
				@Ld_Current_DTTM,                --Update_DTTM             
				@Li_Zero_NUMB,                --TotalReplies_QNTY       
				@Li_Zero_NUMB);               --TotalViews_QNTY         
	            
	   SET @Ln_RowCount_QNTY = @@ROWCOUNT;
	   
	   IF @Ln_RowCount_QNTY  = 0
		BEGIN
		 SET @Ls_DescriptionError_TEXT = 'NOTE_Y1 INSERT FAILED';
		 RAISERROR(50001,16,1);
		END
	END
  
   IF @Ac_ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE
    BEGIN
     SELECT @Ln_Record_QNTY = COUNT(1)
       FROM IWEM_Y1 i
      WHERE i.Case_IDNO = @An_Case_IDNO
        AND i.MemberMci_IDNO = @An_MemberMci_IDNO
        AND i.OthpEmployer_IDNO = @An_OthpSource_IDNO
        AND i.IwnStatus_CODE IN (@Lc_IwnStatusPending_CODE, @Lc_IwnStatusActive_CODE)
        AND i.End_DATE = @Ld_High_DATE
        AND i.EndValidity_DATE = @Ld_High_DATE;

     IF @Ln_Record_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'ELFC0141 :  INSERT IWEM_Y1';
       SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', OthpEmployer_IDNO = ' + ISNULL(CAST(@An_OthpSource_IDNO AS VARCHAR), '');

       INSERT IWEM_Y1
              (Case_IDNO,
               OrderSeq_NUMB,
               MemberMci_IDNO,
               Entered_DATE,
               End_DATE,
               OthpEmployer_IDNO,
               TypeSource_CODE,
               IwnPer_CODE,
               IwnStatus_CODE,
               CurCs_AMNT,
               CurMd_AMNT,
               CurSs_AMNT,
               CurOt_AMNT,
               Payback_AMNT,
               FreqCs_CODE,
               FreqMd_CODE,
               FreqSs_CODE,
               FreqOt_CODE,
               FreqPayback_CODE,
               ArrearAged_INDC,
               BeginValidity_DATE,
               EndValidity_DATE,
               WorkerUpdate_ID,
               Update_DTTM,
               TransactionEventSeq_NUMB)
       SELECT w.Case_IDNO,
              w.OrderSeq_NUMB,
              w.MemberMci_IDNO,
              w.Entered_DATE,
              @Ad_Run_DATE AS End_DATE,
              w.OthpEmployer_IDNO,
              w.TypeSource_CODE,
              w.IwnPer_CODE,
              @Lc_IwnStatusTerminated_CODE AS IwnStatus_CODE,
              w.CurCs_AMNT,
              w.CurMd_AMNT,
              w.CurSs_AMNT,
              w.CurOt_AMNT,
              w.Payback_AMNT,
              w.FreqCs_CODE,
              w.FreqMd_CODE,
              w.FreqSs_CODE,
              w.FreqOt_CODE,
              w.FreqPayback_CODE,
              w.ArrearAged_INDC,
              @Ad_Run_DATE AS BeginValidity_DATE,
              @Ld_High_DATE AS EndValidity_DATE,
              @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
              @Ld_Current_DTTM AS Update_DTTM,
              @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB
         FROM IWEM_Y1 w
        WHERE w.Case_IDNO = @An_Case_IDNO
          AND w.MemberMci_IDNO = @An_MemberMci_IDNO
          AND w.OthpEmployer_IDNO = @An_OthpSource_IDNO
          AND w.IwnStatus_CODE IN (@Lc_IwnStatusPending_CODE, @Lc_IwnStatusActive_CODE)
          AND w.End_DATE = @Ld_High_DATE
          AND w.EndValidity_DATE = @Ld_High_DATE;
          
        SET @Ln_RowCount_QNTY = @@ROWCOUNT;
        
       IF @Ln_RowCount_QNTY  = 0
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'IWEM_Y1 INSERT FAILED';
		 RAISERROR(50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'ELFC0142 :  UPDATE IWEM_Y1';
       SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', OthpEmployer_IDNO = ' + ISNULL(CAST(@An_OthpSource_IDNO AS VARCHAR), '') ;

       UPDATE IWEM_Y1
          SET EndValidity_DATE = @Ad_Run_DATE
        WHERE Case_IDNO = @An_Case_IDNO
          AND MemberMci_IDNO = @An_MemberMci_IDNO
          AND OthpEmployer_IDNO = @An_OthpSource_IDNO
          AND IwnStatus_CODE IN (@Lc_IwnStatusPending_CODE, @Lc_IwnStatusActive_CODE)
          AND End_DATE = @Ld_High_DATE
          AND EndValidity_DATE = @Ld_High_DATE;
          
  SET @Ln_RowCount_QNTY = @@ROWCOUNT;
  
       IF @Ln_RowCount_QNTY  = 0
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'IWEM_Y1 UPDATE FAILED';
		 RAISERROR(50001,16,1);
        END
      END
    END

   SET @Ls_Sql_TEXT = 'ELFC0143 : INSERT HDMJR_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS NVARCHAR(MAX)), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStart_CODE, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS NVARCHAR(MAX)), '');

   --Updating the Remedy to Close the Remedy
   INSERT HDMJR_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           MajorIntSeq_NUMB,
           MemberMci_IDNO,
           ActivityMajor_CODE,
           Subsystem_CODE,
           TypeOthpSource_CODE,
           OthpSource_IDNO,
           Entered_DATE,
           Status_DATE,
           Status_CODE,
           ReasonStatus_CODE,
           BeginExempt_DATE,
           EndExempt_DATE,
           Forum_IDNO,
           TotalTopics_QNTY,
           PostLastPoster_IDNO,
           UserLastPoster_ID,
           SubjectLastPoster_TEXT,
           LastPost_DTTM,
           BeginValidity_DATE,
           EndValidity_DATE,
           WorkerUpdate_ID,
           Update_DTTM,
           TransactionEventSeq_NUMB,
           TypeReference_CODE,
           Reference_ID)
   SELECT j.Case_IDNO,
          j.OrderSeq_NUMB,
          j.MajorIntSeq_NUMB,
          j.MemberMci_IDNO,
          j.ActivityMajor_CODE,
          j.Subsystem_CODE,
          j.TypeOthpSource_CODE,
          j.OthpSource_IDNO,
          j.Entered_DATE,
          j.Status_DATE,
          j.Status_CODE,
          j.ReasonStatus_CODE,
          j.BeginExempt_DATE,
          j.EndExempt_DATE,
          j.Forum_IDNO,
          j.TotalTopics_QNTY,
          j.PostLastPoster_IDNO,
          j.UserLastPoster_ID,
          j.SubjectLastPoster_TEXT,
          j.LastPost_DTTM,
          j.BeginValidity_DATE,
          @Ad_Run_DATE AS BeginValidity_DATE,
          j.WorkerUpdate_ID,
          j.Update_DTTM,
          j.TransactionEventSeq_NUMB,
          j.TypeReference_CODE,
          j.Reference_ID
     FROM DMJR_Y1 j
    WHERE j.Case_IDNO = @An_Case_IDNO
      AND j.Status_CODE = @Lc_StatusStart_CODE
      AND j.MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB;
      
   SET @Ln_RowCount_QNTY = @@ROWCOUNT;
   
   IF @Ln_RowCount_QNTY  = 0
    BEGIN
		SET @Ls_DescriptionError_TEXT = 'HDMJR_Y1 INSERT FAILED';
		RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'ELFC0144 : UPDATE DMJR_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS NVARCHAR(MAX)), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStart_CODE, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS NVARCHAR(MAX)), '');

   UPDATE DMJR_Y1
      SET Status_CODE = @Lc_StatusComplete_CODE,
          ReasonStatus_CODE = @Lc_ReasonStatusBc_CODE,
          Status_DATE = @Ad_Run_DATE,
          BeginValidity_DATE = @Ad_Run_DATE,
          WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
          Update_DTTM = @Ld_Current_DTTM,
          TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
    WHERE DMJR_Y1.Case_IDNO = @An_Case_IDNO
      AND DMJR_Y1.OrderSeq_NUMB = @An_OrderSeq_NUMB
      AND DMJR_Y1.Status_CODE = @Lc_StatusStart_CODE
      AND DMJR_Y1.MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB;
      
  SET @Ln_RowCount_QNTY = @@ROWCOUNT;
  
   IF @Ln_RowCount_QNTY  = 0
    BEGIN
		SET @Ls_DescriptionError_TEXT = 'DMJR_Y1 UPDATE FAILED';
		RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END
    
     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION 
     @As_Procedure_NAME        = @Ls_Routine_TEXT,  
     @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
     @As_Sql_TEXT              = @Ls_Sql_TEXT,
     @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
     @An_Error_NUMB            = @Ln_Error_NUMB,
     @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,  
     @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;	
  END CATCH
 END


GO
