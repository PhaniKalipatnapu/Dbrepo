/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_FLOW_SCHEDULE_GENETIC_INFO]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*      
--------------------------------------------------------------------------------------------------------------------      
Procedure Name    : BATCH_COMMON$SP_FLOW_SCHEDULE_GENETIC_INFO       
Programmer Name   : IMP Team
Description       : The procedure BATCH_COMMON$SP_FLOW_SCHEDULE_GENETIC_INFO is used for inserting the records in GTST_Y1 table through SPRO and GTST screen. Apart from     
                    inserting the record this batch will do the following process    
                    * If more then one parent record added in same schedule number this split the parent record and will insert in separate schedule number.    
                    * Automatic add process take place. That is if NCP/PF record added alone it will check whether any other dep record present in the GTST_Y1    
                      table and bring the dep record and get link with the NCP/PF's schedule number.     
                      In the same way if the dep record added it will check whether any NCP/PF record present in any other schedule number and the dep record     
                      automatically go and insert in the NCP/PF's schedule number.      
Frequency         :     
Developed On      :	04/12/2011
Called BY         : BATCH_COMMON$SP_INSERT_SCHEDULE  
Called On		  : BATCH_COMMON$SP_GENERATE_SCHEDULE_NUMB    
-------------------------------------------------------------------------------------------------------------------    
Modified BY       :      
Modified On       :      
Version No        : 1.0      
--------------------------------------------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_FLOW_SCHEDULE_GENETIC_INFO](
 @An_Case_IDNO				  NUMERIC(6),      
 @An_MemberMci_IDNO           NUMERIC(10),      
 @An_Schedule_NUMB            NUMERIC(10),      
 @An_TransactionEventSeq_NUMB NUMERIC(19),      
 @Ad_Test_DATE                DATE,      
 @An_Test_AMNT                NUMERIC(11),      
 @An_OthpLocation_IDNO        NUMERIC(9),      
 @As_PaidBy_NAME              VARCHAR(60),      
 @Ac_SignedOnWorker_ID        CHAR(30),      
 @As_Lab_NAME                 VARCHAR(60)		= '',      
 @Ac_LocationState_CODE       CHAR(2)			= '',      
 @As_Location_NAME            VARCHAR(100),      
 @An_CountyLocation_IDNO      NUMERIC(3)		= NULL,      
 @Ac_TypeTest_CODE            CHAR(1)			= '',      
 @Ad_ResultsReceived_DATE     DATE,      
 @Ac_TestResult_CODE          CHAR(1),      
 @An_Probability_PCT          NUMERIC(5,2),    
 @Ac_CaseRelationship_CODE    CHAR(1)			= '',    
 @Ac_RecordLast_INDC          CHAR(1),    
 @Ac_Screen_ID                CHAR(4),    
 @An_MajorIntSeq_NUMB         NUMERIC(5)		= NULL,      
 @Ac_Msg_CODE                 CHAR(5)			OUTPUT,    
 @As_DescriptionError_TEXT    VARCHAR(4000)		OUTPUT
 )    
     
 AS    
 BEGIN    
SET NOCOUNT ON;    
    
  DECLARE  @Li_Zero_QNTY					INT				= 0,
           @Lc_TestResultConducted_CODE     CHAR(1)			= 'K',
           @Lc_TestResultCancel_CODE        CHAR(1)			= 'C',
           @Lc_TestResultScheduled_CODE     CHAR(1)			= 'S',
           @Lc_TestResultFailToAppear_CODE  CHAR(1)			= 'F',
           @Lc_CaseRealtionshipNcp_CODE     CHAR(1)			= 'A',
           @Lc_CaseRealtionshipPf_CODE      CHAR(1)			= 'P',
           @Lc_CaseRealtionshipCp_CODE      CHAR(1)			= 'C',
           @Lc_CaseRealtionshipDep_CODE     CHAR(1)			= 'D',
           @Lc_CaseMemberStatusActive_CODE  CHAR(1)			= 'A',
           @Lc_StatusFailed_CODE            CHAR(1)			= 'F',
           @Lc_StatusSchedule_CODE          CHAR(1)			= 'S',
           @Lc_StatusSuccess_CODE           CHAR(1)			= 'S',
           @Lc_Yes_TEXT                     CHAR(1)			= 'Y',
           @Lc_No_TEXT                      CHAR(1)			= 'N',
           @Lc_Concurrency_CODE             CHAR(1)			= 'N',
           @Lc_Inclusion_TEXT               CHAR(1)			= 'I',
           @Lc_ActivityMajorCase_CODE       CHAR(4)			= 'CASE',
           @Lc_ActivityMajorGtst_CODE       CHAR(4)			= 'GTST',
           @Lc_ScreenIndcSPRO_CODE          CHAR(4)			= 'SPRO',
           @Ls_Procedure_NAME               VARCHAR(50)		= 'BATCH_COMMON$SP_FLOW_SCHEDULE_GENETIC_INFO',
           @Ld_Low_DATE                     DATE			= '01/01/0001',
           @Ld_High_DATE                    DATE			= '12/31/9999';
  DECLARE  @Li_Count_QNTY					INT,
           @Li_FetchStatus_QNTY				INT,
           @Li_RowCount_QNTY				INT,
           @Ln_Schedule_NUMB				NUMERIC(10),
           @Ln_Error_NUMB					NUMERIC(10),
           @Ln_ScheduleOrig_NUMB            NUMERIC(10)		= NULL,
           @Ln_RowsAffected_NUMB            NUMERIC(10)		= NULL,
           @Ln_ErrorLine_NUMB				NUMERIC(11),
           @Lc_Blank_TEXT					CHAR(1)			= '',
           @Lc_DateFuture_CODE				CHAR(1),
           @Lc_TestResultValue_CODE			CHAR(1),
           @Lc_TestResult_CODE				CHAR(1),
           @Lc_CaseRelationship_CODE		CHAR(1),
           @Lc_Exists_INDC					CHAR(1),
           @Lc_TypeTestDp_CODE				CHAR(1),
           @Ls_Sql_TEXT						VARCHAR(100),
           @Ls_Sqldata_TEXT					VARCHAR(1000),
           @Ls_ErrorMessage_TEXT			VARCHAR(1000),
           @Ld_TestDateDp_CODE				DATE,
           @Ld_Current_DATE                 DATE			= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
           @Ld_System_DTTM                  DATETIME2		= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
 DECLARE @Ln_CpCUR_MemberMciCp_IDNO			NUMERIC(10),  
   		 @Lc_CpCUR_TypeTestCp_CODE			CHAR(1);  
 DECLARE @Ln_DepCUR_MemberMciDp_IDNO		NUMERIC(10),  
   		 @Lc_DepCUR_TypeTestDp_CODE			CHAR(1);  
 DECLARE @Ln_NcpCUR_MemberMciNcp_IDNO		NUMERIC(10),   
   		 @Lc_NcpCUR_TypeTestNcp_CODE		CHAR(1);  
 DECLARE @Ln_LOTRCUR_MemberMci_IDNO			NUMERIC(10),    
   		 @Ln_LOTRCUR_Schedule_NUMB			NUMERIC(10);  
 DECLARE @Ln_DRASCUR_MemberMciDp_IDNO		NUMERIC(10),  
   	     @Ld_DRASCUR_TestDateDp_CODE		DATE,
   	     @Lc_DRASCUR_TypeTestDp_CODE		CHAR(1);
 DECLARE @Ln_NOPSCUR_ScheduleNcpPf_NUMB		NUMERIC(10);
   
   SET @Lc_Exists_INDC =@Lc_No_TEXT;    
     
BEGIN TRY     
    IF @Ad_ResultsReceived_DATE IS NULL 
    OR @Ad_ResultsReceived_DATE = @Lc_Blank_TEXT    
    BEGIN    
    SET @Ad_ResultsReceived_DATE = @Ld_Low_DATE;    
    END    
    
IF (@Ac_Screen_ID !=@Lc_ScreenIndcSPRO_CODE )    
BEGIN    
        
    IF ( @An_Schedule_NUMB != @Li_Zero_QNTY )
		BEGIN    
		 SET @Ln_Schedule_NUMB = @An_Schedule_NUMB;    
		END     
    ELSE IF ( @An_Schedule_NUMB = @Li_Zero_QNTY)
    BEGIN    
         SET @Ls_Sql_TEXT ='SELECT Schedule_NUMB FROM GTST_Y1';       
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ',TransactionEventSeq_NUMB = ' + CAST(@An_TransactionEventSeq_NUMB AS CHAR(19));
                                   
     SELECT @Ln_Schedule_NUMB = MAX(a.Schedule_NUMB)      
         FROM   GTST_Y1 a      
         WHERE  a.Case_IDNO                = @An_Case_IDNO       
         AND    a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB       
         AND    a.EndValidity_DATE         = @Ld_High_DATE;      
         
    IF ( @Ln_Schedule_NUMB IS NULL 
    OR @Ln_Schedule_NUMB = @Li_Zero_QNTY )    
      BEGIN    
      SET @Ls_Sql_TEXT ='BATCH_COMMON$SP_GENERATE_SCHEDULE_NUMB :';             
      SET @Ls_Sqldata_TEXT = @Lc_Blank_TEXT;   
  
      EXECUTE  BATCH_COMMON$SP_GENERATE_SCHEDULE_NUMB    
               @Ac_Msg_CODE = @Ac_Msg_CODE OUTPUT,    
               @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT,        
            @An_Schedule_NUMB =@Ln_Schedule_NUMB  OUTPUT ;    
           
           IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE      
               BEGIN      
                   RAISERROR (50001, 16, 1);      
               END            
     END ;    
    END;    
        
    IF (@Ad_Test_DATE > @Ld_Current_DATE 
    AND @Ac_CaseRelationship_CODE !=@Lc_CaseRealtionshipDep_CODE )    
		BEGIN    
		 SET @Lc_DateFuture_CODE = @Lc_Yes_TEXT;    
		END;    
    IF ( @Ac_CaseRelationship_CODE !=@Lc_CaseRealtionshipDep_CODE )     
    BEGIN    
     IF ( @As_PaidBy_NAME =  @Lc_Blank_TEXT 
       OR @As_PaidBy_NAME IS NULL )     
     BEGIN    
      SET @Lc_TestResultValue_CODE = CASE 
      									 WHEN @Ac_TestResult_CODE = @Lc_Blank_TEXT 
      									   OR @Ac_TestResult_CODE IS NULL   
						                 THEN @Lc_TestResultScheduled_CODE   
						                 ELSE @Ac_TestResult_CODE   
						                 END;    
     END;    
     ELSE    
     BEGIN     
      SET @Lc_TestResultValue_CODE = @Lc_TestResultConducted_CODE;    
     END;      
         
     IF (@Lc_DateFuture_CODE =@Lc_Yes_TEXT)     
     BEGIN    
      SET @Lc_TestResult_CODE =@Lc_TestResultScheduled_CODE;    
     END;    
     ELSE    
     BEGIN    
            SET @Lc_TestResult_CODE = @Lc_TestResultValue_CODE ;    
        END;    
   END -- This will come for dep part    
   ELSE    
   BEGIN    
     SET @Lc_TestResult_CODE = @Ac_TestResult_CODE;    
   END;    
       
   IF (@Ac_CaseRelationship_CODE =@Lc_CaseRealtionshipDep_CODE )     
   BEGIN     
         
   SET @Ls_Sql_TEXT = 'SELECT 1 From GTST_Y1 ';      
 SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS CHAR(10)) + ',Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ',Schedule_NUMB = ' + CAST(@Ln_Schedule_NUMB AS CHAR(10));   
  
   SELECT TOP 1 @Lc_Exists_INDC = @Lc_Yes_TEXT                                                         
         FROM   GTST_Y1 a                                                                                     
         WHERE a.MemberMci_IDNO  = @An_MemberMci_IDNO                                                             
         AND   a.Case_IDNO       = @An_Case_IDNO                                                             
         AND   a.TestResult_CODE  NOT IN (@Lc_TestResultFailToAppear_CODE,@Lc_TestResultCancel_CODE)      
         AND   a.Schedule_NUMB    = @Ln_Schedule_NUMB                                                         
         AND   a.EndValidity_DATE = @Ld_High_DATE;      
             
      IF ( @Lc_Exists_INDC ='Y')     
      BEGIN    
         SET @Ac_Msg_CODE  = 'E0152' ;    
         RETURN;    
      END;    
    END;       
  END    
  ELSE    
  BEGIN 
       IF (@Ac_Screen_ID =@Lc_ScreenIndcSPRO_CODE)    
       BEGIN    
         SET @Ln_Schedule_NUMB = @An_Schedule_NUMB;    
         SET @Lc_TestResult_CODE = @Lc_TestResultScheduled_CODE;    
      
  IF (@Ac_TypeTest_CODE = @Lc_Blank_Text)  
  BEGIN  
    SET @Ls_Sql_TEXT ='SELECT TypeReference_CODE FROM DMJR_Y1';    
    SET @Ls_Sqldata_TEXT = 'MajorIntSeq_NUMB = ' + CAST(@An_MajorIntSeq_NUMB AS CHAR(5)) + ',Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6));   
  
    SELECT @Ac_TypeTest_CODE = D.TypeReference_CODE      
     FROM DMJR_Y1 D      
    WHERE D.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB      
      AND D.Case_IDNO = @An_Case_IDNO      
      AND D.ActivityMajor_CODE IN (@Lc_ActivityMajorGtst_CODE, @Lc_ActivityMajorCase_CODE);      
  END  
         SET @Ls_Sql_TEXT='SELECT OtherParty_NAME,State_ADDR,County_IDNO FROM OTHP_Y1';   
         SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(CAST(@An_OthpLocation_IDNO AS VARCHAR), @Lc_Blank_TEXT); 
  
        SELECT @As_Lab_NAME = O.OtherParty_NAME,      
          @Ac_LocationState_CODE = O.State_ADDR,       
          @An_CountyLocation_IDNO = O.County_IDNO    
         FROM OTHP_Y1 O      
        WHERE O.OtherParty_IDNO = @An_OthpLocation_IDNO      
		AND O.EndValidity_DATE = @Ld_High_DATE;       
      END;    
  END;    
    SET @Ls_Sql_TEXT = 'INSERT INTO GTST_Y1-1 ';      
    SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ', MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS CHAR(10)) + ', Schedule_NUMB = ' + CAST(@Ln_Schedule_NUMB AS CHAR(10)) + ', Test_DATE = ' + CAST(@Ad_Test_DATE AS CHAR(10)) + ', Test_AMNT = ' + CAST(@An_Test_AMNT AS VARCHAR) + ', OthpLocation_IDNO = ' + ISNULL(CAST(@An_OthpLocation_IDNO AS VARCHAR), @Lc_Blank_TEXT) + ',PaidBy_NAME = ' + ISNULL(@As_PaidBy_NAME, @Lc_Blank_TEXT) + ', WorkerUpdate_ID = ' + @Ac_SignedOnWorker_ID + ', TransactionEventSeq_NUMB = ' + CAST(@An_TransactionEventSeq_NUMB AS CHAR(19)) + ', Lab_NAME = ' + ISNULL(@As_Lab_NAME, @Lc_Blank_TEXT) + ', LocationState_CODE = ' + ISNULL(@Ac_LocationState_CODE, @Lc_Blank_TEXT) + ', Location_NAME = ' + ISNULL(@As_Location_NAME, @Lc_Blank_TEXT) + ', CountyLocation_IDNO = ' + ISNULL(CAST(@An_CountyLocation_IDNO AS VARCHAR), @Lc_Blank_TEXT) + ', TypeTest_CODE = ' + @Ac_TypeTest_CODE + ', ResultsReceived_DATE = ' + ISNULL(CAST(@Ad_ResultsReceived_DATE AS VARCHAR), @Lc_Blank_TEXT) + ', TestResult_CODE = ' + ISNULL(@Lc_TestResult_CODE, @Lc_Blank_TEXT) + ', Probability_PCT = ' + ISNULL(CAST(@An_Probability_PCT AS VARCHAR), @Lc_Blank_TEXT);   
  
   IF  (@Ac_Screen_ID <> @Lc_ScreenIndcSPRO_CODE)
   BEGIN        
         SELECT @Lc_Concurrency_CODE = @Lc_Yes_TEXT FROM GTST_Y1 g WITH (Readuncommitted )
                  WHERE g.Case_IDNO        = @An_Case_IDNO
              		AND g.MemberMci_IDNO   = @An_MemberMci_IDNO
              		AND g.TestResult_CODE  = @Lc_TestResultScheduled_CODE
              		AND g.TypeTest_CODE    = @Ac_TypeTest_CODE;
              
	     IF (@Lc_Concurrency_CODE = @Lc_No_TEXT )
	     BEGIN
		     SELECT @Lc_Concurrency_CODE = @Lc_Yes_TEXT FROM GTST_Y1 g 
		        WHERE g.Case_IDNO        = @An_Case_IDNO
		          AND g.MemberMci_IDNO   = @An_MemberMci_IDNO
		          AND g.TestResult_CODE  = @Lc_TestResultScheduled_CODE
		          AND g.TypeTest_CODE    = @Ac_TypeTest_CODE;
	     END;
    END;
                       
     IF (@Lc_Concurrency_CODE = @Lc_No_TEXT )   
     BEGIN
		       INSERT INTO GTST_Y1    
		       (Case_IDNO                ,        
		     MemberMci_IDNO              ,    
		     Schedule_NUMB               ,    
		     Test_DATE                   ,    
		     Test_AMNT                   ,    
		     OthpLocation_IDNO           ,    
		     PaidBy_NAME                 ,    
		     BeginValidity_DATE          ,    
		     EndValidity_DATE            ,    
		     WorkerUpdate_ID             ,    
		     Update_DTTM                 ,    
		     TransactionEventSeq_NUMB    ,    
		     Lab_NAME                    ,    
		     LocationState_CODE          ,    
		     Location_NAME               ,    
		     CountyLocation_IDNO         ,    
		     TypeTest_CODE               ,    
		     ResultsReceived_DATE        ,    
		     TestResult_CODE             ,    
		     Probability_PCT)            
		     VALUES(@An_Case_IDNO ,					--Case_IDNO  
		         @An_MemberMci_IDNO ,				--MemberMci_IDNO  
		         @Ln_Schedule_NUMB ,				--Schedule_NUMB  
		         @Ad_Test_DATE,						--Test_DATE  
		         @An_Test_AMNT,						--Test_AMNT  
		         @An_OthpLocation_IDNO ,			--OthpLocation_IDNO  
		         @As_PaidBy_NAME,					--PaidBy_NAME  
		         @Ld_Current_DATE ,					--BeginValidity_DATE  
		         @Ld_High_DATE ,					--EndValidity_DATE  
		         @Ac_SignedOnWorker_ID,				--WorkerUpdate_ID  
		         @Ld_System_DTTM ,					--Update_DTTM  
		         @An_TransactionEventSeq_NUMB ,		--TransactionEventSeq_NUMB  
		         @As_Lab_NAME ,						--Lab_NAME  
		         @Ac_LocationState_CODE ,			--LocationState_CODE  
		         @As_Location_NAME ,				--Location_NAME  
		         @An_CountyLocation_IDNO ,			--CountyLocation_IDNO  
		         @Ac_TypeTest_CODE ,				--TypeTest_CODE  
		         @Ad_ResultsReceived_DATE ,			--ResultsReceived_DATE  
		         @Lc_TestResult_CODE ,				--TestResult_CODE  
		         @An_Probability_PCT				--Probability_PCT  
		    ) ;          
		    
		   SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;      
		   IF @Ln_RowsAffected_NUMB = @Li_Zero_QNTY     
		    BEGIN      
		       SET @Ls_ErrorMessage_TEXT = 'INSERT INTO GTST FAILED';
       			RAISERROR (50001,16,1);
		    END;       
   END
    ELSE
    BEGIN
            SET @Ac_Msg_CODE  = 'E0152' ;      
		     RETURN;          
    END;
       SET  @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;    
        
IF @Ac_RecordLast_INDC =@Lc_Yes_TEXT    
BEGIN    
    SET @Ln_ScheduleOrig_NUMB = @Ln_Schedule_NUMB ;    
    SET @Ln_Schedule_NUMB =@Li_Zero_QNTY;    
           
       DECLARE Cp_CUR INSENSITIVE CURSOR FOR      
         SELECT  MemberMci_IDNO ,        
                 TypeTest_CODE          
                 FROM  GTST_Y1 g        
                 WHERE g.Case_IDNO   = @An_Case_IDNO        
                 AND g.SCHEDULE_NUMB = @Ln_ScheduleOrig_NUMB        
                 AND g.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB        
                 AND g.MemberMci_IDNO IN ( SELECT MemberMci_IDNO         
                                                  FROM CMEM_Y1 c        
                                                  WHERE c.Case_IDNO = @An_Case_IDNO        
                                                  AND   c.CaseRelationship_CODE =@Lc_CaseRealtionshipCp_CODE         
                                                  AND   c.CaseMemberStatus_CODE   =@Lc_CaseMemberStatusActive_CODE )        
                 AND g.TestResult_CODE NOT IN (@Lc_TestResultConducted_CODE , @Lc_TestResultCancel_CODE )        
                 AND g.EndValidity_DATE = @Ld_High_DATE;           
                  
     SET @Ls_Sql_TEXT ='SELECT  COUNT(1) FROM GTST_Y1';                   
    SET @Ls_Sqldata_TEXT ='Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ',Schedule_NUMB = ' + CAST(@Ln_ScheduleOrig_NUMB AS CHAR(10));     
  
    SELECT @Li_Count_QNTY = COUNT(1)          
         FROM GTST_Y1 g          
         WHERE g.Case_IDNO =@An_Case_IDNO          
         AND g.Schedule_NUMB=@Ln_ScheduleOrig_NUMB          
         AND g.EndValidity_DATE=@Ld_High_DATE          
         AND g.MemberMci_IDNO IN (SELECT membermci_idno           
                      FROM CMEM_Y1 c           
                      WHERE c.Case_IDNO = @An_Case_IDNO        
                        AND c.caserelationship_code IN (@Lc_CaseRealtionshipNcp_CODE,@Lc_CaseRealtionshipPf_CODE,@Lc_CaseRealtionshipCp_CODE)          
                        AND c.CaseMemberStatus_Code =@Lc_CaseMemberStatusActive_CODE)            
         AND g.TypeTest_CODE NOT IN (@Lc_TestResultConducted_CODE,@Lc_TestResultCancel_CODE);           
          
     IF (@Li_Count_QNTY >1)
     BEGIN      
     OPEN Cp_CUR ;
     
     FETCH NEXT FROM Cp_CUR INTO @Ln_CpCUR_MemberMciCp_IDNO,@Lc_CpCUR_TypeTestCp_CODE;      
     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;    
     --now we will get the cp record    
     WHILE @Li_FetchStatus_QNTY=@Li_Zero_QNTY     
     BEGIN      
                 
      SET @Ln_Schedule_NUMB =@Li_Zero_QNTY;      
           
      SET @Ls_Sql_TEXT ='BATCH_COMMON$SP_GENERATE_SCHEDULE_NUMB :';    
             
      SET @Ls_Sqldata_TEXT = @Lc_Blank_TEXT;  
  
      EXECUTE  BATCH_COMMON$SP_GENERATE_SCHEDULE_NUMB      
               @Ac_Msg_CODE = @Ac_Msg_CODE OUTPUT,    
               @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT,        
            @An_Schedule_NUMB =@Ln_Schedule_NUMB  OUTPUT ;    
           
           IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE      
               BEGIN      
                   RAISERROR (50001, 16, 1);      
               END        
         
       SET @Ls_Sql_TEXT = 'UPDATE-1 GTST_Y1';       
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ',Schedule_NUMB = ' + CAST(@Ln_ScheduleOrig_NUMB AS CHAR(10)) + ',MemberMci_IDNO = ' + CAST(@Ln_CpCUR_MemberMciCp_IDNO AS CHAR(10)) + ', TransactionEventSeq_NUMB = ' + CAST(@An_TransactionEventSeq_NUMB AS CHAR(19)) + ', TypeTest_CODE = ' + @Lc_CpCUR_TypeTestCp_CODE;
  
          UPDATE GTST_Y1             
          SET EndValidity_DATE =  @Ld_System_DTTM             
          OUTPUT Deleted.Case_IDNO,               
          	     Deleted.MemberMci_IDNO,               
          	     @Ln_Schedule_NUMB AS Schedule_NUMB,     
          	     Deleted.Test_DATE,               
          	     Deleted.Test_AMNT,               
          	     Deleted.OthpLocation_IDNO,               
          	     Deleted.PaidBy_NAME,               
          	     @Ld_System_DTTM AS BeginValidity_DATE,               
          	     @Ld_High_DATE    AS EndValidity_DATE,               
          	     @Ac_SignedOnWorker_ID   AS WorkerUpdate_ID,               
          	     @Ld_System_DTTM AS Update_DTTM,               
          	     Deleted.TransactionEventSeq_NUMB,               
          	     Deleted.Lab_NAME,               
          	     Deleted.LocationState_CODE,             
          	     Deleted.Location_NAME,            
          	     Deleted.CountyLocation_IDNO,              
          	     Deleted.TypeTest_CODE,              
          	     Deleted.ResultsReceived_DATE,            
          	     Deleted.TestResult_CODE,            
          	     Deleted.Probability_PCT            
          INTO GTST_Y1            
          WHERE Case_IDNO       = @An_Case_IDNO             
          AND  Schedule_NUMB   = @Ln_ScheduleOrig_NUMB             
          AND  MemberMci_IDNO  = @Ln_CpCUR_MemberMciCp_IDNO       --cp member mci      
          AND  TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB             
          AND  TypeTest_CODE = @Lc_CpCUR_TypeTestCp_CODE    --cp type test    
          AND  EndValidity_DATE  = @Ld_High_DATE;            
              
       SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;            
           
       IF @Ln_RowsAffected_NUMB = @Li_Zero_QNTY      
       BEGIN      
       	   SET @Ls_ErrorMessage_TEXT =  ' UPDATE GTST FAILED ';
           RAISERROR (50001,16,1);    
       END;    
                   
          DECLARE Dep_CUR INSENSITIVE CURSOR FOR      
           SELECT MemberMci_IDNO,        
                TypeTest_CODE         
                  FROM  GTST_Y1 g        
                WHERE g.Case_IDNO   = @An_Case_IDNO        
                AND g.SCHEDULE_NUMB = @Ln_ScheduleOrig_NUMB        
                AND g.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB        
                AND g.MemberMci_IDNO IN ( SELECT MemberMci_IDNO         
                                                   FROM CMEM_Y1 c        
                                                   WHERE c.Case_IDNO = @An_Case_IDNO        
                                                   AND c.CaseRelationship_CODE =@Lc_CaseRealtionshipDep_CODE         
                                                   AND c.CaseMemberStatus_CODE   =@Lc_CaseMemberStatusActive_CODE )        
                  AND g.TestResult_CODE NOT IN (@Lc_TestResultFailToAppear_CODE , @Lc_TestResultCancel_CODE )        
                  AND g.EndValidity_DATE = @Ld_High_DATE;
                         
       OPEN Dep_CUR;
       
       FETCH NEXT FROM Dep_CUR INTO @Ln_DepCUR_MemberMciDp_IDNO,@Lc_DepCUR_TypeTestDp_CODE;     
        
       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;   
        
       -- Now get the dep record added in single transaction and also for the schedule number that generated initially for the transaction number      
       WHILE @Li_FetchStatus_QNTY=@Li_Zero_QNTY      
       BEGIN       
          SET @Ls_Sql_TEXT = 'LOGICAL UPDATE-2 GTST_Y1';     
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ', Schedule_NUMB = ' + CAST(@Ln_ScheduleOrig_NUMB AS CHAR(10))+ ', MemberMci_IDNO = ' + CAST(@Ln_DepCUR_MemberMciDp_IDNO AS CHAR(10)) + ',TransactionEventSeq_NUMB = ' + CAST(@An_TransactionEventSeq_NUMB AS CHAR(19)) + ', TypeTest_CODE = ' + ISNULL(@Lc_DepCUR_TypeTestDp_CODE, @Lc_Blank_TEXT) + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), @Lc_Blank_TEXT);
  
           UPDATE GTST_Y1             
           SET EndValidity_DATE =  @Ld_System_DTTM             
           OUTPUT Deleted.Case_IDNO,               
           		  Deleted.MemberMci_IDNO,               
           		  @Ln_Schedule_NUMB AS Schedule_NUMB, 
           		  Deleted.Test_DATE,               
           		  Deleted.Test_AMNT,               
           		  Deleted.OthpLocation_IDNO,               
           		  Deleted.PaidBy_NAME,               
           		  @Ld_System_DTTM AS BeginValidity_DATE,               
           		  @Ld_High_DATE    AS EndValidity_DATE,               
           		  @Ac_SignedOnWorker_ID   AS WorkerUpdate_ID,               
           		  @Ld_System_DTTM AS Update_DTTM,               
           		  Deleted.TransactionEventSeq_NUMB,               
           		  Deleted.Lab_NAME,               
           		  Deleted.LocationState_CODE,             
           		  Deleted.Location_NAME,            
           		  Deleted.CountyLocation_IDNO,              
           		  Deleted.TypeTest_CODE,              
           		  Deleted.ResultsReceived_DATE,            
           		  Deleted.TestResult_CODE,            
           		  Deleted.Probability_PCT            
           INTO GTST_Y1            
           WHERE Case_IDNO       = @An_Case_IDNO             
           AND  Schedule_NUMB   = @Ln_ScheduleOrig_NUMB             
           AND  MemberMci_IDNO  = @Ln_DepCUR_MemberMciDp_IDNO
           AND  TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB             
           AND  TypeTest_CODE = @Lc_DepCUR_TypeTestDp_CODE        
           AND  EndValidity_DATE  = @Ld_High_DATE;            
               
          SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;      
                
          IF @Ln_RowsAffected_NUMB = @Li_Zero_QNTY      
          BEGIN      
            SET @Ls_ErrorMessage_TEXT =  ' UPDATE GTST FAILED ';
           		RAISERROR (50001,16,1);
          END;       
            
          FETCH NEXT FROM Dep_CUR INTO @Ln_DepCUR_MemberMciDp_IDNO,@Lc_DepCUR_TypeTestDp_CODE;    
           
           SET @Li_FetchStatus_QNTY = @@FETCH_STATUS ;    
           
       END;      
       
       CLOSE Dep_CUR;   
          
       DEALLOCATE Dep_CUR;    
     
     FETCH NEXT FROM Cp_CUR INTO @Ln_CpCUR_MemberMciCp_IDNO,@Lc_CpCUR_TypeTestCp_CODE;  
         
     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;    
     
     END       
     
     CLOSE Cp_CUR;
     DEALLOCATE Cp_CUR;    
    
    SET @Ln_DepCUR_MemberMciDp_IDNO = @Li_Zero_QNTY;      
    SET @Lc_DepCUR_TypeTestDp_CODE =@Lc_Blank_TEXT;      
      
    DECLARE Ncp_CUR INSENSITIVE CURSOR FOR      
         SELECT MemberMci_IDNO ,        
              TypeTest_CODE          
             FROM  GTST_Y1 g        
            WHERE g.Case_IDNO   = @An_Case_IDNO        
            AND g.SCHEDULE_NUMB = @Ln_ScheduleOrig_NUMB        
            AND g.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB        
            AND g.MemberMci_IDNO IN ( SELECT MemberMci_IDNO         
                            FROM CMEM_Y1 c         
                            WHERE c.Case_IDNO = @An_Case_IDNO        
                            AND c.CaseRelationship_CODE IN (@Lc_CaseRealtionshipNcp_CODE ,@Lc_CaseRealtionshipPf_CODE)        
                            AND c.CaseMemberStatus_CODE   =@Lc_CaseMemberStatusActive_CODE )        
            AND g.TestResult_CODE NOT IN (@Lc_TestResultConducted_CODE , @Lc_TestResultCancel_CODE )        
            AND g.EndValidity_DATE = @Ld_High_DATE;         
            
      OPEN Ncp_CUR;
      FETCH NEXT FROM Ncp_CUR INTO @Ln_NcpCUR_MemberMciNcp_IDNO,@Lc_NcpCUR_TypeTestNcp_CODE;      
      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;    
       --This will retrieve the NCP record added in single transaction and also the schedule number that generated for the transaction      
      WHILE @Li_FetchStatus_QNTY=@Li_Zero_QNTY      
      BEGIN      
          SET @Ln_Schedule_NUMB = @Li_Zero_QNTY;      
              
          SET @Ls_Sql_TEXT ='BATCH_COMMON$SP_GENERATE_SCHEDULE_NUMB :';    
             
      SET @Ls_Sqldata_TEXT = @Lc_Blank_TEXT; 
  
      EXECUTE  BATCH_COMMON$SP_GENERATE_SCHEDULE_NUMB       
               @Ac_Msg_CODE = @Ac_Msg_CODE OUTPUT,    
               @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT,        
               @An_Schedule_NUMB =@Ln_Schedule_NUMB  OUTPUT ;    
           
           IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE      
               BEGIN      
                   RAISERROR (50001, 16, 1);      
               END        
                   
          SET @Ls_Sql_TEXT = 'UPDATE-3 GTST_Y1';      
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ', Schedule_NUMB = ' + CAST(@Ln_ScheduleOrig_NUMB AS CHAR(10)) + ', MemberMci_IDNO = ' + CAST(@Ln_NcpCUR_MemberMciNcp_IDNO AS CHAR(10)) + ', TransactionEventSeq_NUMB = ' + CAST(@An_TransactionEventSeq_NUMB AS CHAR(19)) + ', TypeTest_CODE = ' + ISNULL(@Lc_NcpCUR_TypeTestNcp_CODE, @Lc_Blank_TEXT);
  
          UPDATE GTST_Y1             
          SET EndValidity_DATE =  @Ld_System_DTTM             
          OUTPUT Deleted.Case_IDNO,               
          		 Deleted.MemberMci_IDNO,               
          		 @Ln_Schedule_NUMB AS Schedule_NUMB,            
          		 Deleted.Test_DATE,               
          		 Deleted.Test_AMNT,               
          		 Deleted.OthpLocation_IDNO,               
          		 Deleted.PaidBy_NAME,               
          		 @Ld_System_DTTM AS BeginValidity_DATE,               
          		 @Ld_High_DATE    AS EndValidity_DATE,               
          		 @Ac_SignedOnWorker_ID   AS WorkerUpdate_ID,               
          		 @Ld_System_DTTM AS Update_DTTM,               
          		 Deleted.TransactionEventSeq_NUMB,               
          		 Deleted.Lab_NAME,               
          		 Deleted.LocationState_CODE,             
          		 Deleted.Location_NAME,            
          		 Deleted.CountyLocation_IDNO,              
          		 Deleted.TypeTest_CODE,              
          		 Deleted.ResultsReceived_DATE,            
          		 Deleted.TestResult_CODE,            
          		 Deleted.Probability_PCT            
          INTO GTST_Y1            
          WHERE Case_IDNO       = @An_Case_IDNO             
          AND  Schedule_NUMB   = @Ln_ScheduleOrig_NUMB             
          AND  MemberMci_IDNO  = @Ln_NcpCUR_MemberMciNcp_IDNO
          AND  TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB             
          AND  TypeTest_CODE = @Lc_NcpCUR_TypeTestNcp_CODE
          AND  EndValidity_DATE  = @Ld_High_DATE;       
             
          SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;            
          IF @Ln_RowsAffected_NUMB = @Li_Zero_QNTY      
          BEGIN      
             SET @Ls_ErrorMessage_TEXT =  ' UPDATE GTST FAILED ';
            RAISERROR (50001,16,1);  
          END      
              
          DECLARE DepN_CUR INSENSITIVE CURSOR FOR      
           SELECT MemberMci_IDNO,        
                TypeTest_CODE         
                  FROM  GTST_Y1 g        
                WHERE g.Case_IDNO   = @An_Case_IDNO        
                AND g.SCHEDULE_NUMB = @Ln_ScheduleOrig_NUMB        
                AND g.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB        
                AND g.MemberMci_IDNO IN ( SELECT MemberMci_IDNO         
                                                   FROM CMEM_Y1 c        
                                                   WHERE c.Case_IDNO = @An_Case_IDNO        
                                                   AND c.CaseRelationship_CODE =@Lc_CaseRealtionshipDep_CODE         
                                                   AND c.CaseMemberStatus_CODE   =@Lc_CaseMemberStatusActive_CODE )        
                  AND g.TestResult_CODE NOT IN (@Lc_TestResultFailToAppear_CODE , @Lc_TestResultCancel_CODE )        
                  AND g.EndValidity_DATE = @Ld_High_DATE;        
                    
         OPEN DepN_CUR;
         FETCH NEXT FROM DepN_CUR INTO @Ln_DepCUR_MemberMciDp_IDNO,@Lc_DepCUR_TypeTestDp_CODE;      
          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;    
           -- This will retrieve the dependent record added in single transaction and single schedule number that created in this transaction      
         WHILE @Li_FetchStatus_QNTY=@Li_Zero_QNTY      
          BEGIN       
             SET @Ls_Sql_TEXT =  'UPDATE-4 GTST_Y1';        
             SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ',  Schedule_NUMB = ' + CAST(@Ln_ScheduleOrig_NUMB AS CHAR(10))+ ',MemberMci_IDNO = '  + CAST(@Ln_DepCUR_MemberMciDp_IDNO AS CHAR(10)) + ', TransactionEventSeq_NUMB = ' + CAST(@An_TransactionEventSeq_NUMB AS CHAR(19)) + ', TypeTest_CODE = ' + ISNULL(@Lc_DepCUR_TypeTestDp_CODE, @Lc_Blank_TEXT) + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), @Lc_Blank_TEXT);  
  
            UPDATE GTST_Y1             
            SET EndValidity_DATE =  @Ld_System_DTTM             
            OUTPUT Deleted.Case_IDNO,               
            	   Deleted.MemberMci_IDNO,               
            	   @Ln_Schedule_NUMB AS Schedule_NUMB,            
            	   Deleted.Test_DATE,               
            	   Deleted.Test_AMNT,               
            	   Deleted.OthpLocation_IDNO,               
            	   Deleted.PaidBy_NAME,               
            	   @Ld_System_DTTM AS BeginValidity_DATE,               
            	   @Ld_High_DATE    AS EndValidity_DATE,               
            	   @Ac_SignedOnWorker_ID   AS WorkerUpdate_ID,               
            	   @Ld_System_DTTM AS Update_DTTM,               
            	   Deleted.TransactionEventSeq_NUMB,               
            	   Deleted.Lab_NAME,               
            	   Deleted.LocationState_CODE,             
            	   Deleted.Location_NAME,            
            	   Deleted.CountyLocation_IDNO,              
            	   Deleted.TypeTest_CODE,              
            	   Deleted.ResultsReceived_DATE,            
            	   Deleted.TestResult_CODE,            
            	   Deleted.Probability_PCT            
            INTO GTST_Y1            
            WHERE Case_IDNO       = @An_Case_IDNO             
            AND  Schedule_NUMB   = @Ln_ScheduleOrig_NUMB             
            AND  MemberMci_IDNO  = @Ln_DepCUR_MemberMciDp_IDNO
            AND  TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB             
            AND  TypeTest_CODE = @Lc_DepCUR_TypeTestDp_CODE
            AND  EndValidity_DATE  = @Ld_High_DATE;            
                  
            SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;            
                   
            IF @Ln_RowsAffected_NUMB = @Li_Zero_QNTY      
            BEGIN      
           	  SET @Ls_ErrorMessage_TEXT =  ' UPDATE GTST FAILED ';
              RAISERROR (50001,16,1); 
            END      
              
              FETCH NEXT FROM DepN_CUR INTO @Ln_DepCUR_MemberMciDp_IDNO,@Lc_DepCUR_TypeTestDp_CODE;      
              SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;    
            END;      
         CLOSE DepN_CUR;      
         DEALLOCATE DepN_CUR;    
    
         FETCH NEXT FROM Ncp_CUR INTO @Ln_NcpCUR_MemberMciNcp_IDNO,@Lc_NcpCUR_TypeTestNcp_CODE;       
         SET @Li_FetchStatus_QNTY = @@FETCH_STATUS  ;        
      END;      
      CLOSE Ncp_CUR;    
      DEALLOCATE Ncp_CUR;    
          
     SET @Ln_ScheduleOrig_NUMB =NULL;      
    
    END;  
   SET @Ln_Schedule_NUMB =@Li_Zero_QNTY;      
      
     DECLARE LOTR_CUR INSENSITIVE CURSOR FOR       
              SELECT MemberMci_IDNO,        
                     Schedule_NUMB         
                  FROM GTST_Y1 g          
                  WHERE g.Case_IDNO  =@An_Case_IDNO           
                  AND g.schedule_NUMB  = ISNULL(@Ln_ScheduleOrig_NUMB , g.schedule_NUMB )  -- here for @Ln_ScheduleOrig_NUMB we made as NULL only it will retrieve the record based on transactio only      
                  AND g.EndValidity_DATE =@Ld_High_DATE          
                  AND g.TestResult_CODE NOT IN (@Lc_TestResultConducted_CODE,@Lc_TestResultCancel_CODE,@Lc_TestResultFailToAppear_CODE)          
                  AND g.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB  ;        
          
    OPEN LOTR_CUR;      
       FETCH NEXT FROM LOTR_CUR INTO @Ln_LOTRCUR_MemberMci_IDNO,@Ln_LOTRCUR_Schedule_NUMB;      
       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;    
       --This will retrieve the records that inserted in this transaction     
       WHILE @Li_FetchStatus_QNTY=@Li_Zero_QNTY       
       BEGIN      
        SET @Ls_Sql_TEXT =  'SELECT CaseRelationship_CODE FROM CMEM_Y1';  
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ', MemberMci_IDNO = ' + CAST(@Ln_LOTRCUR_MemberMci_IDNO AS CHAR(10)) + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE, @Lc_Blank_TEXT);  
  
         SELECT @Lc_CaseRelationship_CODE = a.CaseRelationship_CODE        
            FROM CMEM_Y1 a        
           WHERE a.Case_IDNO = @An_Case_IDNO        
             AND a.MemberMci_IDNO = @Ln_LOTRCUR_MemberMci_IDNO    
             AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;        
           
    IF @Lc_CaseRelationship_CODE IN ( @Lc_CaseRealtionshipNcp_CODE,@Lc_CaseRealtionshipPf_CODE)  -- For NCP and PF the following process take place       
    BEGIN           
       DECLARE DRAS_CUR INSENSITIVE CURSOR FOR       
       SELECT x.MemberMci_IDNO,              
             x.Test_DATE,              
             x.TypeTest_CODE                    
             FROM ( SELECT DISTINCT 
                        MemberMci_IDNO,              
                        Test_DATE,              
                        TypeTest_CODE               
                        FROM GTST_Y1 g              
                        WHERE g.Case_IDNO = @An_Case_IDNO              
                        AND g.Schedule_NUMB !=@Ln_LOTRCUR_Schedule_NUMB        
                        AND g.MemberMci_IDNO IN (SELECT MemberMci_IDNO               
                                              FROM CMEM_Y1 c              
                                                WHERE c.case_idno=@An_Case_IDNO              
                                            AND c.caserelationship_code=@Lc_CaseRealtionshipDep_CODE              
                                            AND c.casememberstatus_code=@Lc_CaseMemberStatusActive_CODE)              
                     AND g.EndValidity_DATE=@Ld_High_DATE              
                     AND g.Test_Date = (SELECT MAX(Test_DATE)              
                                         FROM GTST_Y1 s              
                                         WHERE s.Case_IDNO = @An_Case_IDNO         
                                         AND s.MemberMci_IDNO =g.MemberMci_IDNO              
                                         AND s.EndValidity_DATE=@Ld_High_DATE              
                                         AND s.TestResult_CODE NOT IN (@Lc_TestResultCancel_CODE,@Lc_TestResultFailToAppear_CODE,@Lc_Inclusion_Text ))              
                     AND g.TransactionEventSeq_NUMB = ( SELECT MAX(TransactionEventSeq_NUMB)         
                                              FROM GTST_Y1 e        
                                              WHERE e.Case_IDNO=@An_Case_IDNO        
                                              AND   e.MemberMci_IDNO = g.MemberMci_IDNO          
                                              AND   e.Test_DATE = g.Test_DATE        
                                              AND   e.EndValidity_DATE=@Ld_High_DATE          
                                              AND   e.TestResult_CODE NOT IN (@Lc_TestResultCancel_CODE,@Lc_TestResultFailToAppear_CODE,@Lc_Inclusion_Text ) )          
                     AND g.TestResult_CODE NOT IN (@Lc_TestResultCancel_CODE,@Lc_TestResultFailToAppear_CODE,@Lc_Inclusion_Text )              
                     AND NOT EXISTS( SELECT 1           
                                 FROM GTST_Y1 s           
                                 WHERE s.Case_IDNO    = @An_Case_IDNO          
                                 AND s.Schedule_NUMB  = @Ln_LOTRCUR_Schedule_NUMB      
                                 AND s.MemberMci_IDNO = g.MemberMci_IDNO           
                                 AND s.EndValidity_DATE=@Ld_High_DATE            
                                 AND s.TestResult_CODE NOT IN (@Lc_TestResultCancel_CODE,@Lc_TestResultFailToAppear_CODE,@Lc_Inclusion_TEXT))) X  ;     
             
             OPEN DRAS_CUR;    
             FETCH NEXT FROM DRAS_CUR INTO @Ln_DRASCUR_MemberMciDp_IDNO,@Ld_DRASCUR_TestDateDp_CODE,@Lc_DRASCUR_TypeTestDp_CODE;      
            
             SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;    
          -- This will retrieve the dep record present in any other schedule number    
           WHILE @Li_FetchStatus_QNTY=@Li_Zero_QNTY        
            BEGIN      
                   
             SET @Ls_Sql_TEXT = 'INSERT INTO GTST_Y1-2';      
             SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ', MemberMci_IDNO = ' + CAST(@Ln_DRASCUR_MemberMciDp_IDNO AS CHAR(10)) + ', Schedule_NUMB = ' + CAST(@Ln_LOTRCUR_Schedule_NUMB AS CHAR(10))+ ', Test_DATE = ' + CAST(@Ld_DRASCUR_TestDateDp_CODE AS VARCHAR) + ', Test_AMNT = ' + ISNULL(CAST(@Li_Zero_QNTY AS VARCHAR), @Lc_Blank_TEXT) + ', OthpLocation_IDNO = ' + ISNULL(CAST(@Li_Zero_QNTY AS VARCHAR), @Lc_Blank_TEXT) + ', PaidBy_NAME = ' + ISNULL(@Lc_Blank_TEXT, @Lc_Blank_TEXT) + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Current_DATE AS VARCHAR), @Lc_Blank_TEXT) + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), @Lc_Blank_TEXT) + ', WorkerUpdate_ID = ' + ISNULL(@Ac_SignedOnWorker_ID, @Lc_Blank_TEXT) + ', Update_DTTM = ' + ISNULL(CAST(@Ld_System_DTTM AS VARCHAR), @Lc_Blank_TEXT) + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS VARCHAR), @Lc_Blank_TEXT) + ', Lab_NAME = ' + ISNULL(@Lc_Blank_TEXT, @Lc_Blank_TEXT) + ', LocationState_CODE = ' + ISNULL(@Lc_Blank_TEXT, @Lc_Blank_TEXT) + ', Location_NAME = ' + ISNULL(@Lc_Blank_TEXT, @Lc_Blank_TEXT) + ', CountyLocation_IDNO = ' + ISNULL(CAST(@Li_Zero_QNTY AS VARCHAR), @Lc_Blank_TEXT) + ', TypeTest_CODE = ' + ISNULL(@Lc_DRASCUR_TypeTestDp_CODE, @Lc_Blank_TEXT) + ', ResultsReceived_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), @Lc_Blank_TEXT) + ', TestResult_CODE = ' + ISNULL(@Lc_StatusSchedule_CODE, @Lc_Blank_TEXT) + ', Probability_PCT = ' + ISNULL(CAST(@Li_Zero_QNTY AS VARCHAR), @Lc_Blank_TEXT);
 
             INSERT INTO GTST_Y1      
			   (Case_IDNO                  ,          
			   MemberMci_IDNO              ,      
			   Schedule_NUMB               ,      
			   Test_DATE                   ,      
			   Test_AMNT                   ,      
			   OthpLocation_IDNO           ,      
			   PaidBy_NAME                 ,      
			   BeginValidity_DATE          ,      
			   EndValidity_DATE            ,      
			   WorkerUpdate_ID             ,      
			   Update_DTTM                 ,      
			   TransactionEventSeq_NUMB    ,      
			   Lab_NAME                    ,      
			   LocationState_CODE          ,      
			   Location_NAME               ,      
			   CountyLocation_IDNO         ,      
			   TypeTest_CODE               ,      
			   ResultsReceived_DATE        ,      
			   TestResult_CODE             ,      
			   Probability_PCT)              
           VALUES(@An_Case_IDNO ,             --Case_IDNO  
				@Ln_DRASCUR_MemberMciDp_IDNO,     --MemberMci_IDNO  
				@Ln_LOTRCUR_Schedule_NUMB,        --Schedule_NUMB  
				@Ld_DRASCUR_TestDateDp_CODE,      --Test_DATE  
				@Li_Zero_QNTY,                                --Test_AMNT  
				@Li_Zero_QNTY ,                               --OthpLocation_IDNO  
				@Lc_Blank_TEXT,                               --PaidBy_NAME  
				@Ld_Current_DATE ,            --BeginValidity_DATE  
				@Ld_High_DATE ,                   --EndValidity_DATE  
				@Ac_SignedOnWorker_ID,            --WorkerUpdate_ID  
				@Ld_System_DTTM ,         --Update_DTTM  
				@An_TransactionEventSeq_NUMB ,    --TransactionEventSeq_NUMB  
				@Lc_Blank_TEXT ,                              --Lab_NAME  
				@Lc_Blank_TEXT ,                              --LocationState_CODE  
				@Lc_Blank_TEXT ,                              --Location_NAME  
				@Li_Zero_QNTY ,                               --CountyLocation_IDNO  
				@Lc_DRASCUR_TypeTestDp_CODE,      --TypeTest_CODE  
				@Ld_Low_DATE ,                    --ResultsReceived_DATE  
				@Lc_StatusSchedule_CODE ,          --TestResult_CODE  
				@Li_Zero_QNTY  --Probability_PCT  
     ) ;                           
                  
               SET @Li_RowCount_QNTY = @@ROWCOUNT;           
               IF @Li_RowCount_QNTY = @Li_Zero_QNTY      
            BEGIN      
        		 SET @Ls_ErrorMessage_TEXT =  ' INSERT INTO GTST FAILED ';
                 RAISERROR (50001,16,1);  
            END      
              
            FETCH NEXT FROM DRAS_CUR INTO @Ln_DRASCUR_MemberMciDp_IDNO,@Ld_DRASCUR_TestDateDp_CODE,@Lc_DRASCUR_TypeTestDp_CODE;      
             SET @Li_FetchStatus_QNTY = @@FETCH_STATUS ;         
           END ;      
    
             CLOSE DRAS_CUR;        
             DEALLOCATE DRAS_CUR;    
    END; 
    ELSE IF ( @Lc_CaseRelationship_CODE =@Lc_CaseRealtionshipDep_CODE)
    BEGIN
      SET @Ls_Sql_TEXT = ' SELECT Test_Date,TypeTest_CODE FROM GTST_Y1';     
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST( @An_Case_IDNO AS CHAR(6) )+', MemberMci_IDNO = ' + CAST( @Ln_LOTRCUR_MemberMci_IDNO AS CHAR(10) )+', Schedule_NUMB = ' + CAST( @Ln_LOTRCUR_Schedule_NUMB AS CHAR(10) )+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),@Lc_Blank_TEXT);   
  
      SELECT @Ld_TestDateDp_CODE = Test_Date,        
             @Lc_TypeTestDp_CODE = TypeTest_CODE         
             FROM GTST_Y1 g        
             WHERE g.Case_IDNO    = @An_Case_IDNO        
             AND g.MemberMci_IDNO =@Ln_LOTRCUR_MemberMci_IDNO    
             AND g.Schedule_NUMB = @Ln_LOTRCUR_Schedule_NUMB    
             AND g.EndValidity_DATE=@Ld_High_DATE        
             AND g.TestResult_CODE NOT IN (@Lc_TestResultCancel_CODE,@Lc_TestResultFailToAppear_CODE)        
             AND g.Test_DATE=(SELECT MAX(Test_DATE)         
                                     FROM GTST_Y1 s        
                                     WHERE s.Case_IDNO   =@An_Case_IDNO         
                                     AND s.schedule_NUMB =@Ln_LOTRCUR_Schedule_NUMB    
                                     AND s.MemberMci_IDNO=g.MemberMci_IDNO        
                                     AND s.EndValidity_DATE = @Ld_High_DATE        
                                     AND s.TestResult_CODE NOT IN (@Lc_TestResultCancel_CODE,@Lc_TestResultFailToAppear_CODE));        
        DECLARE NOPS_CUR INSENSITIVE CURSOR FOR           
            SELECT  Schedule_NUMB         
              FROM GTST_Y1 g        
			 WHERE g.Case_IDNO = @An_Case_IDNO        
                        AND g.Schedule_NUMB != @Ln_LOTRCUR_Schedule_NUMB    
                        AND g.MemberMci_IDNO IN (SELECT MemberMci_IDNO         
                                FROM CMEM_Y1 c        
                                WHERE c.case_idno=@An_Case_IDNO        
                                AND c.caserelationship_code IN (@Lc_CaseRealtionshipNcp_CODE,@Lc_CaseRealtionshipPf_CODE)         
                                AND c.casememberstatus_code=@Lc_CaseMemberStatusActive_CODE)        
              AND g.EndValidity_DATE=@Ld_High_DATE        
              AND g.TestResult_CODE NOT IN (@Lc_TestResultConducted_CODE,@Lc_TestResultCancel_CODE)        
              AND NOT EXISTS ( SELECT 1         
                           FROM GTST_Y1 s         
                           WHERE s.Case_IDNO    = @An_Case_IDNO        
                           AND s.Schedule_NUMB  = g.Schedule_NUMB        
                           AND s.MemberMci_IDNO = @Ln_LOTRCUR_MemberMci_IDNO    
                           AND s.EndValidity_DATE=@Ld_High_DATE          
                           AND s.TestResult_CODE NOT IN (@Lc_TestResultCancel_CODE,@Lc_TestResultFailToAppear_CODE) );        
              
          OPEN NOPS_CUR;      
             FETCH NEXT FROM NOPS_CUR INTO @Ln_NOPSCUR_ScheduleNcpPf_NUMB;      
             SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;    
             --- This will retrieve the NCP/PF schedule number present in some other transaction    
         WHILE @Li_FetchStatus_QNTY=@Li_Zero_QNTY        
             BEGIN      
                SET @Ls_Sql_TEXT = 'INSERT INTO GTST_Y1-3';                      
                SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ', MemberMci_IDNO = ' + CAST(@Ln_LOTRCUR_MemberMci_IDNO AS CHAR(10)) + ', Schedule_NUMB = ' + CAST(@Ln_NOPSCUR_ScheduleNcpPf_NUMB AS CHAR(10)) + ', Test_DATE = ' + CAST(@Ld_TestDateDp_CODE AS CHAR(10)) + ', WorkerUpdate_ID = ' + @Ac_SignedOnWorker_ID + ', Update_DTTM = ' + ISNULL(CAST(@Ld_System_DTTM AS VARCHAR), @Lc_Blank_TEXT) + ', TransactionEventSeq_NUMB = ' + CAST(@An_TransactionEventSeq_NUMB AS CHAR(19)) + ', TypeTest_CODE = ' + @Lc_TypeTestDp_CODE;   
  
                INSERT INTO GTST_Y1      
                (Case_IDNO                   ,          
                MemberMci_IDNO              ,      
                Schedule_NUMB               ,      
                Test_DATE                   ,      
                Test_AMNT                   ,      
                OthpLocation_IDNO           ,      
                PaidBy_NAME                 ,      
                BeginValidity_DATE          ,      
                EndValidity_DATE            ,      
                WorkerUpdate_ID             ,      
                Update_DTTM                 ,      
                TransactionEventSeq_NUMB    ,      
                Lab_NAME                    ,      
                LocationState_CODE          ,      
                Location_NAME               ,      
                CountyLocation_IDNO         ,      
                TypeTest_CODE               ,      
                ResultsReceived_DATE        ,      
                TestResult_CODE             ,      
                Probability_PCT)              
                VALUES(@An_Case_IDNO ,                 --Case_IDNO  
                 @Ln_LOTRCUR_MemberMci_IDNO ,          --MemberMci_IDNO  
                 @Ln_NOPSCUR_ScheduleNcpPf_NUMB,       --Schedule_NUMB  
                 @Ld_TestDateDp_CODE,                  --Test_DATE  
                 @Li_Zero_QNTY,                                    --Test_AMNT  
                 @Li_Zero_QNTY,                                    --OthpLocation_IDNO  
                 @Lc_Blank_TEXT,                                   --PaidBy_NAME  
                 @Ld_Current_DATE ,                --BeginValidity_DATE  
                 @Ld_High_DATE ,                       --EndValidity_DATE  
                 @Ac_SignedOnWorker_ID,                --WorkerUpdate_ID  
                 @Ld_System_DTTM ,             --Update_DTTM  
                 @An_TransactionEventSeq_NUMB ,        --TransactionEventSeq_NUMB  
                 @Lc_Blank_TEXT ,                                  --Lab_NAME  
                 @Lc_Blank_TEXT ,                                  --LocationState_CODE  
                 @Lc_Blank_TEXT ,            --Location_NAME  
                 @Li_Zero_QNTY ,                                   --CountyLocation_IDNO  
                 @Lc_TypeTestDp_CODE ,                 --TypeTest_CODE  
                 @Ld_Low_DATE ,                        --ResultsReceived_DATE  
                 @Lc_StatusSchedule_CODE ,                                 --TestResult_CODE  
                 @Li_Zero_QNTY  --Probability_PCT  
 ) ;                                
                     
                 SET @Li_RowCount_QNTY = @@ROWCOUNT;                 
                 IF @Li_RowCount_QNTY = @Li_Zero_QNTY      
           BEGIN      
             SET @Ls_ErrorMessage_TEXT =  'INSERT INTO GTST FAILED';
             RAISERROR (50001,16,1);
           END;      
           
            FETCH NEXT FROM NOPS_CUR INTO @Ln_NOPSCUR_ScheduleNcpPf_NUMB; 
                 
            SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;        
            
            END;       
            
         CLOSE NOPS_CUR;      
         
         DEALLOCATE NOPS_CUR;    
         
    END;      
          
     FETCH NEXT FROM LOTR_CUR INTO @Ln_LOTRCUR_MemberMci_IDNO,@Ln_LOTRCUR_Schedule_NUMB;     
      
     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS ;   
      
    END;      
    
    CLOSE LOTR_CUR;  
          
    DEALLOCATE LOTR_CUR;        
    SET @Ac_Msg_CODE=@Lc_StatusSuccess_CODE;      
 END;    
          
 END TRY    
     
 BEGIN CATCH     
      
	   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;      
       
       SET @Ln_Error_NUMB = ERROR_NUMBER();      
       SET @Ln_ErrorLine_NUMB = ERROR_LINE();      
   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;          
     
       IF CURSOR_STATUS('Local', 'Cp_CUR') IN (0, 1)      
        BEGIN      
          CLOSE Cp_CUR;      
          DEALLOCATE Cp_CUR;      
        END;      
            
         IF CURSOR_STATUS('Local', 'Dep_CUR') IN (0, 1)      
        BEGIN      
          CLOSE Dep_CUR;      
          DEALLOCATE Dep_CUR;      
        END;      
            
         IF CURSOR_STATUS('Local', 'Ncp_CUR') IN (0, 1)      
        BEGIN      
          CLOSE Ncp_CUR;      
          DEALLOCATE Ncp_CUR;      
        END;      
            
          IF CURSOR_STATUS('Local', 'DepN_CUR') IN (0, 1)      
        BEGIN      
          CLOSE DepN_CUR;      
          DEALLOCATE DepN_CUR;      
        END;      
            
         IF CURSOR_STATUS('Local', 'LOTR_CUR') IN (0, 1)      
        BEGIN      
          CLOSE LOTR_CUR;      
          DEALLOCATE LOTR_CUR;      
        END;      
            
         IF CURSOR_STATUS('Local', 'DRAS_CUR') IN (0, 1)      
        BEGIN      
          CLOSE DRAS_CUR;      
          DEALLOCATE DRAS_CUR;      
        END;      
            
         IF CURSOR_STATUS('Local', 'NOPS_CUR') IN (0, 1)      
        BEGIN      
          CLOSE NOPS_CUR;      
          DEALLOCATE NOPS_CUR;      
        END;      
            
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION      
    @As_Procedure_NAME        = @Ls_Procedure_NAME,      
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,      
    @As_Sql_TEXT              = @Ls_Sql_TEXT,      
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,      
    @An_Error_NUMB            = @Ln_Error_NUMB,      
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,      
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;      
        
 END CATCH ;    
 END; 
GO
