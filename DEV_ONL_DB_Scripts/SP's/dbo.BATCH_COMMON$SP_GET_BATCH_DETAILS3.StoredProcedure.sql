/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_GET_BATCH_DETAILS3]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_COMMON$SP_GET_BATCH_DETAILS3
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get the run date, last run date , commit freq and exception        
				  threshold for a given batch process.
Frequency		:	
Developed On	:	4/4/2011
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_GET_BATCH_DETAILS3](        
 @Ac_Job_ID								CHAR(7),        
 @Ad_Run_DATE							DATE OUTPUT,        
 @Ad_LastRun_DATE						DATE OUTPUT,        
 @An_CommitFreq_QNTY					NUMERIC(5) OUTPUT,        
 @An_ExceptionThreshold_QNTY			NUMERIC(5) OUTPUT,        
 @As_File_NAME							VARCHAR(60) OUTPUT,        
 @As_FileLocationInputPath_TEXT			VARCHAR(80) OUTPUT,    
 @As_FileLocationOutputPath_TEXT		VARCHAR(80) OUTPUT,
 @As_FileLocationLogPath_TEXT			VARCHAR(200) OUTPUT,
 @As_FileLocationArchivePath_TEXT		VARCHAR(200) OUTPUT,
 @As_Process_NAME						VARCHAR(100) OUTPUT,        
 @As_Procedure_NAME						VARCHAR(100) OUTPUT,    
 @Ac_Msg_CODE							CHAR(1) OUTPUT,        
 @As_DescriptionError_TEXT				VARCHAR(4000) OUTPUT        
 )        
AS        
  
 BEGIN        
 SET NOCOUNT ON;        
  DECLARE  @Lc_StatusFailed_CODE        CHAR(1) = 'F',        
           @Lc_StatusSuccess_CODE       CHAR(1) = 'S',        
           @Lc_IoDirectionInputI_INDC   CHAR(1) = 'I',        
           @Lc_IoDirectionOutputO_INDC  CHAR(1) = 'O',        
           @Lc_IoDirectionOutputN_INDC  CHAR(1) = 'N',        
           @Lc_JobDaily_ID			    CHAR(7) = 'DAILY',        
           @Ls_Routine_TEXT             VARCHAR(60) = 'BATCH_COMMON$SP_GET_BATCH_DETAILS3',        
           @Ld_High_DATE                DATE = '12/31/9999';        
  DECLARE  @Ln_Error_NUMB             NUMERIC(10),        
           @Ln_ErrorLine_NUMB         NUMERIC(11),        
           @Li_Rowcount_QNTY          SMALLINT,        
           @Lc_JobFreq_CODE           CHAR(1),        
           @Lc_FileIo_CODE            CHAR(1),     
           @Ls_ServerPath_NAME		  VARCHAR(60),   
           @Ls_Sql_TEXT               VARCHAR(200),        
           @Ls_PackageProcedure_NAME  VARCHAR(200),        
           @Ls_Sqldata_TEXT           VARCHAR(1000),        
           @Ls_ErrorMessage_TEXT      VARCHAR(4000) = '';        
          
  BEGIN TRY        
   SET @Ad_Run_DATE = '';        
   SET @Ad_LastRun_DATE = '';        
   SET @An_CommitFreq_QNTY = 0;        
   SET @An_ExceptionThreshold_QNTY = 0;        
   SET @As_File_NAME = '';        
   SET @As_FileLocationInputPath_TEXT = '';        
   SET @As_FileLocationOutputPath_TEXT = '';        
   SET @Ac_Msg_CODE = '';        
   SET @Ls_ErrorMessage_TEXT = '';        
   SET @As_DescriptionError_TEXT = '';        
   
   SET @Ls_Sql_TEXT = 'SELECT PARM_Y1 ';        
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
        
   SELECT @Ad_LastRun_DATE = p.Run_DATE,        
          @Lc_JobFreq_CODE = p.JobFreq_CODE,        
          @Lc_FileIo_CODE = p.FileIo_CODE,        
          @An_CommitFreq_QNTY = p.CommitFreq_QNTY,        
          @An_ExceptionThreshold_QNTY = p.ExceptionThreshold_QNTY,        
          @As_File_NAME = p.File_NAME,     
          @Ls_ServerPath_NAME = p. ServerPath_NAME, 
          @As_Process_NAME = Process_NAME  ,    
          @As_Procedure_NAME = Procedure_NAME,      
          @Ls_PackageProcedure_NAME = ISNULL(p.Process_NAME, '') + '.' + ISNULL(p.Procedure_NAME, '')        
     FROM PARM_Y1 p        
    WHERE p.Job_ID = @Ac_Job_ID        
      AND p.EndValidity_DATE = @Ld_High_DATE;        
        
   SET @Li_Rowcount_QNTY = @@ROWCOUNT;        
        
   IF @Li_Rowcount_QNTY = 0        
    BEGIN        
     SET @Ls_ErrorMessage_TEXT = 'ERROR = NO DATA FOUND IN PARM_Y1/ENVG_Y1 FOR THE JOB';        
     RAISERROR (50001,16,1);        
    END        
   ELSE        
    BEGIN        
     IF @Li_Rowcount_QNTY = 1        
      BEGIN        
       SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;        
      END        
     ELSE        
      BEGIN        
       SET @Ls_ErrorMessage_TEXT = 'ERROR = TOO MANY ROWS FOUND IN PARM_Y1/ENVG_Y1 FOR THE JOB';        
       RAISERROR (50001,16,1);        
      END        
    END        
        
   SET @Ls_Sql_TEXT = 'SELECT PARM_Y1 - 2 ';        
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobDaily_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
        
   SELECT @Ad_Run_DATE = p.Run_DATE        
     FROM PARM_Y1 p        
    WHERE p.Job_ID = @Lc_JobDaily_ID        
      AND p.EndValidity_DATE = @Ld_High_DATE;        
        
   SET @Li_Rowcount_QNTY = @@ROWCOUNT;        
        
   IF @Li_Rowcount_QNTY = 0        
    BEGIN        
     SET @Ls_ErrorMessage_TEXT = 'ERROR = NO DATA FOUND IN PARM_Y1/ENVG_Y1 FOR THE JOB';        
     RAISERROR (50001,16,1);        
    END        
   ELSE        
    BEGIN        
     IF @Li_Rowcount_QNTY = 1        
      BEGIN        
       SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;        
      END        
     ELSE        
      BEGIN        
       SET @Ls_ErrorMessage_TEXT = 'ERROR = TOO MANY ROWS FOUND IN PARM_Y1/ENVG_Y1 FOR THE JOB';        
       RAISERROR (50001,16,1);        
      END        
    END      
    
  IF @Lc_FileIo_CODE IN (@Lc_IoDirectionInputI_INDC,@Lc_IoDirectionOutputO_INDC,@Lc_IoDirectionOutputN_INDC)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT ENVG_Y1 ';
     SET @Ls_Sqldata_TEXT = '';
     SELECT @As_FileLocationInputPath_TEXT = e.InputPath_TEXT,
			@As_FileLocationOutputPath_TEXT =  e.OutputPath_TEXT
       FROM ENVG_Y1 e;
	   
     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT='NO RECORD FOUND IN ENVG_Y1';

       RAISERROR (50001,16,1);
      END
    END
   ELSE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR = NO FILE I/O TYPE AVAILABLE FOR THE JOB';

     RAISERROR (50001,16,1);
    END
    
    SET @As_FileLocationInputPath_TEXT = REPLACE(@As_FileLocationInputPath_TEXT,'\input\','\addressnormalization\input\') + LTRIM(RTRIM(@Ls_ServerPath_NAME));
    SET @As_FileLocationOutputPath_TEXT = REPLACE(@As_FileLocationOutputPath_TEXT,'\output\','\addressnormalization\output\') + LTRIM(RTRIM(@Ls_ServerPath_NAME));
    SET @As_FileLocationLogPath_TEXT = REPLACE(@As_FileLocationInputPath_TEXT,'\input\','\log\') ;
    SET @As_FileLocationArchivePath_TEXT = REPLACE(@As_FileLocationInputPath_TEXT,'\input\','\input\archive\');
    
   ---- Generate file with date            
   IF( @As_File_NAME LIKE '%CCYYMMDD%')         
   BEGIN        
      SET  @As_File_NAME = REPLACE(@As_File_NAME,'CCYYMMDD', CONVERT(VARCHAR(8),@Ad_Run_DATE,112));        
   END    
   IF(@As_File_NAME LIKE '%YYMMDD%')
    BEGIN
     SET @As_File_NAME = REPLACE(@As_File_NAME, 'YYMMDD', CONVERT(VARCHAR(8), @Ad_Run_DATE, 12));
    END
   IF(@As_File_NAME LIKE '%hhmm%')
    BEGIN
     SET @As_File_NAME = REPLACE(@As_File_NAME, 'hhmm', '0000');
    END  
       
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;   
   SET @As_DescriptionError_TEXT = '';        
  END TRY        
        
  BEGIN CATCH        
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;        
   SET @Ln_Error_NUMB = ERROR_NUMBER();          
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();         

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END
             
 	 EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION         
	 @As_Procedure_NAME    = @Ls_Routine_TEXT,          
	 @As_ErrorMessage_TEXT   = @Ls_ErrorMessage_TEXT,        
	 @As_Sql_TEXT     = @Ls_Sql_TEXT,        
	 @As_Sqldata_TEXT       = @Ls_Sqldata_TEXT,        
	 @An_Error_NUMB     = @Ln_Error_NUMB,        
	 @An_ErrorLine_NUMB    = @Ln_ErrorLine_NUMB,          
	 @As_DescriptionError_TEXT = @As_DescriptionError_TEXT      OUTPUT;       
	   
  END CATCH        
 END 
GO
