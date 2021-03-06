/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S121]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
*     PROCEDURE NAME    : DMNR_RETRIEVE_S121
*     DESCRIPTION       : Retrieves the Alert count based on functional area and Worker Name				
*     DEVELOPED BY      : IMP Team
*     DEVELOPED ON      : 1-NOV-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S121](    
 @Ac_Worker_ID     CHAR(30),    
 @An_Case_IDNO     NUMERIC(6, 0),    
 @Ac_File_ID      CHAR(15),    
 @An_Office_IDNO     NUMERIC(3, 0),    
 @Ad_From_DATE     DATE,    
 @Ad_To_DATE      DATE,    
 @Ac_DaysOverdue_QNTY   CHAR(3),    
 @Ac_Category_CODE    CHAR(2),    
 @Ac_SubCategory_CODE   CHAR(4),    
 @Ac_ActivityMinor_CODE   CHAR(5),    
 @Ac_OrderOfDisplay_TEXT   CHAR(4),    
 @Ac_TypeCase_CODE    CHAR(1),    
 @Ac_RespondInit_CODE   CHAR(1),    
 @An_County_IDNO     NUMERIC(3, 0),    
 @An_OfficeCentralExists_INDC NUMERIC(2, 0),    
 @Ai_RecordLevel_NUMB   INT,    
 @Ai_RowFrom_NUMB    INT,    
 @Ai_RowTo_NUMB     INT    
)    
AS    
BEGIN    
 DECLARE    
  @Li_Zero_NUMB     INT = 0,  
  @Li_One_NUMB     INT = 1,
  @Li_Two_NUMB     INT = 2,
  @Li_Three_NUMB     INT = 3,
  @Li_Four_NUMB     INT = 4,  
  @Lc_ActionAlert_CODE   CHAR(1) = 'A',    
  @Lc_AlertStatusWarning_CODE   CHAR(7) = 'WARNING', 
  @Lc_AlertStatusFourOrMoreDays_CODE   CHAR(17) = 'FOUR OR MORE DAYS', 
  @Lc_AlertStatusOverDueToWorker_CODE   CHAR(17) = 'OVERDUE TO WORKER', 
  @Lc_AlertStatusDueToday_CODE   CHAR(9) = 'DUE TODAY', 
  @Lc_StatusStart_CODE   CHAR(4) = 'STRT',    
  @Lc_Empty_TEXT     CHAR(1) = '',    
  @Ld_Current_DATE    DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),    
  @Ld_High_DATE     DATE = '12/31/9999';    
    
 DECLARE      
  @Ls_OuterSelect_TEXT   NVARCHAR(MAX) = ' ',    
  @Ls_AssignedSelectDmnr_TEXT  NVARCHAR(MAX) = ' ',    
  @Ls_WhereAppend_TEXT   NVARCHAR(MAX) = ' ',    
  @Ls_DaysOverdue_TEXT   VARCHAR(300) = ' ',    
  @Ls_OrderOfDisplay_TEXT   VARCHAR(100) = ' ',    
  @Ls_Alias_TEXT     NVARCHAR(MAX) = ' ',    
  @Ls_Query_TEXT     NVARCHAR(MAX) = ' ',    
  @Ls_WorkerList_TEXT    NVARCHAR(MAX) = ' ', 
  @Ls_ParameterDefination_TEXT  NVARCHAR(MAX) = ' ',   
  @Ls_WorkerDelegate_TEXT   NVARCHAR(MAX) = ' ';    
  
 SET @Ls_ParameterDefination_TEXT =   
    N' @Ac_Worker_ID     CHAR(30),    
 @An_Case_IDNO     NUMERIC(6, 0),    
 @Ac_File_ID      CHAR(15),    
 @An_Office_IDNO     NUMERIC(3, 0),    
 @Ad_From_DATE     DATE,    
 @Ad_To_DATE      DATE,    
 @Ac_DaysOverdue_QNTY   CHAR(3),    
 @Ac_Category_CODE    CHAR(2),    
 @Ac_SubCategory_CODE   CHAR(4),    
 @Ac_ActivityMinor_CODE   CHAR(5),    
 @Ac_OrderOfDisplay_TEXT   CHAR(4),    
 @Ac_TypeCase_CODE    CHAR(1),    
 @Ac_RespondInit_CODE   CHAR(1),    
 @An_County_IDNO     NUMERIC(3, 0),    
 @An_OfficeCentralExists_INDC NUMERIC(2, 0), 
 @Ls_DaysOverdue_TEXT   VARCHAR(300),   
 @Ai_RecordLevel_NUMB   INT,    
 @Ai_RowFrom_NUMB    INT,    
 @Ai_RowTo_NUMB     INT  ,
 @Li_Zero_NUMB     INT,  
  @Li_One_NUMB     INT ,
  @Li_Two_NUMB     INT ,
  @Li_Three_NUMB     INT ,
  @Li_Four_NUMB     INT ,  
  @Lc_ActionAlert_CODE   CHAR(1) ,    
  @Lc_AlertStatusWarning_CODE   CHAR(7) , 
  @Lc_AlertStatusFourOrMoreDays_CODE   CHAR(17), 
  @Lc_AlertStatusOverDueToWorker_CODE   CHAR(17) , 
  @Lc_AlertStatusDueToday_CODE   CHAR(9), 
  @Lc_StatusStart_CODE   CHAR(4) ,    
  @Lc_Empty_TEXT     CHAR(1),    
  @Ld_Current_DATE    DATE ,    
  @Ld_High_DATE     DATE '  ;
 
    
 IF @Ac_OrderOfDisplay_TEXT IS NOT NULL    
 BEGIN    
  SET @Ls_OrderOfDisplay_TEXT = ' D.Due_DATE ' + @Ac_OrderOfDisplay_TEXT;    
 END    
 ELSE    
 BEGIN    
  SET @Ls_OrderOfDisplay_TEXT = ' D.Due_DATE ';    
 END    
     

 IF @Ai_RecordLevel_NUMB != @Li_Zero_NUMB    
 BEGIN    
  SET @Ls_WorkerList_TEXT =    
   'WITH Usrl as    
  ( SELECT DISTINCT Worker_ID, Supervisor_ID    
      FROM USRL_Y1 F   
     WHERE F.EndValidity_DATE =  CONVERT(VARCHAR(10), @Ld_High_DATE, 111)    
       AND F.Expire_DATE = CONVERT(VARCHAR(10), @Ld_High_DATE, 111) 
       AND F.Office_IDNO =  CONVERT(VARCHAR(3), @An_Office_IDNO)      
   ),      
 WorkersListTemp        
 AS (SELECT '+ CONVERT(VARCHAR(1), @Li_One_NUMB) +' RecordLevel_NUMB,    
     CAST(@Ac_Worker_ID  AS CHAR(30)) Worker_ID,      
      CAST('''' AS CHAR(30)) Supervisor_ID,         
      '+CONVERT(VARCHAR(1), @Li_Zero_NUMB)+' AS Cycle_NUMB,        
      CAST(''.' + 'CAST(@Ac_Worker_ID AS CHAR(30))' + '.'' AS VARCHAR(MAX)) AS RootPath_TEXT           
  UNION ALL        
  SELECT RecordLevel_NUMB + '+CONVERT(VARCHAR(1), @Li_One_NUMB)+' RecordLevel_NUMB,    
      U2.Worker_ID,        
      U2.Supervisor_ID,        
      CASE        
          WHEN W.RootPath_TEXT LIKE ''%.'' + U2.Worker_ID + ''.%'' THEN '+CONVERT(VARCHAR(1), @Li_One_NUMB)+'        
       ELSE '+CONVERT(VARCHAR(1), @Li_Zero_NUMB)+'        
      END AS Cycle_NUMB,        
      W.RootPath_TEXT + U2.Worker_ID + ''.'' AS RootPath_TEXT    
    FROM Usrl U2        
      INNER JOIN WorkersListTemp W        
     ON U2.Supervisor_ID = W.Worker_ID        
   WHERE W.Cycle_NUMB = CONVERT(VARCHAR(1), @Li_Zero_NUMB)       
 ) ,  
 WorkersList  as         
(select Distinct RecordLevel_NUMB,Worker_ID,  
 Supervisor_ID  
 FROM WorkersListTemp W           
 where Cycle_NUMB = CONVERT(VARCHAR(1), @Li_Zero_NUMB)  
 )';    
  SET @Ls_WorkerDelegate_TEXT =     
   'D.WorkerDelegate_ID IN    
   (    
    SELECT     
     @Ac_Worker_ID     
    UNION ALL    
    SELECT DISTINCT    
     W.Worker_ID    
    FROM    
     WorkersList W    
    WHERE    
     W.RecordLevel_NUMB >=  CONVERT(VARCHAR(2), @Ai_RecordLevel_NUMB )    
   ) AND    
   ';    
 END    
 ELSE    
 BEGIN    
  SET @Ls_WorkerDelegate_TEXT = 'D.WorkerDelegate_ID = @Ac_Worker_ID  AND ';    
 END    
     
 SET @Ls_OuterSelect_TEXT =    
  ' SELECT A.Case_IDNO, 
       A.MemberMci_IDNO, 
       A.Due_DATE, 
       A.ActivityMinor_CODE, 
       A.WorkerDelegate_ID, 
       A.Subsystem_CODE, 
       A.ActionAlert_CODE,       
       A.Priority_QNTY,
        CASE WHEN A.Priority_QNTY = '+CONVERT(VARCHAR(1), @Li_Three_NUMB)+' THEN @Lc_AlertStatusWarning_CODE
              WHEN A.Priority_QNTY = '+CONVERT(VARCHAR(1), @Li_Four_NUMB)+' THEN @Lc_AlertStatusFourOrMoreDays_CODE
              WHEN A.Priority_QNTY ='+CONVERT(VARCHAR(1), @Li_One_NUMB)+' THEN @Lc_AlertStatusOverDueToWorker_CODE
              ELSE @Lc_AlertStatusDueToday_CODE
              END AlertStatus_CODE,
              A.RowCount_NUMB 
       FROM(
       SELECT 
       A.Case_IDNO, 
       A.MemberMci_IDNO, 
       A.Due_DATE, 
       A.ActivityMinor_CODE, 
       A.WorkerDelegate_ID, 
       A.Subsystem_CODE, 
       A.ActionAlert_CODE, 
       A.RowCount_NUMB,
         CASE WHEN DaysDifference_NUMB>'+CONVERT(VARCHAR(1), @Li_Zero_NUMB)+' AND DaysDifference_NUMB <= WarningDaysCount_QNTY THEN '+CONVERT(VARCHAR(1), @Li_Three_NUMB)+'
              WHEN DaysDifference_NUMB>'+CONVERT(VARCHAR(1), @Li_Zero_NUMB)+' AND DaysDifference_NUMB > WarningDaysCount_QNTY THEN '+CONVERT(VARCHAR(1), @Li_Four_NUMB)+'
              WHEN DaysDifference_NUMB<'+CONVERT(VARCHAR(1), @Li_Zero_NUMB)+' THEN '+CONVERT(VARCHAR(1), @Li_One_NUMB)+'
              ELSE '+CONVERT(VARCHAR(1), @Li_Two_NUMB)+'
              END Priority_QNTY,ROW_NUMB 
        FROM
        (SELECT    
   A.Case_IDNO,    
   A.MemberMci_IDNO,    
   A.Due_DATE,    
   A.ActivityMinor_CODE,    
   A.WorkerDelegate_ID,    
   A.Subsystem_CODE,    
   A.ActionAlert_CODE,    
   A.RowCount_NUMB,
   DATEDIFF ( D , (SELECT dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()), A.Due_DATE ) DaysDifference_NUMB, 
   3+dbo.BATCH_COMMON$SF_CALCULATE_BUSINESS_DAYS((SELECT dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),A.Due_DATE,1) WarningDaysCount_QNTY,
   ROW_NUMB    
   FROM (';    
 SET @Ls_AssignedSelectDmnr_TEXT =     
  'SELECT    
   D.Case_IDNO,    
   D.MemberMci_IDNO,    
   D.Due_DATE,    
   D.ActivityMinor_CODE,    
   D.WorkerDelegate_ID,    
   D.Subsystem_CODE,    
   M.ActionAlert_CODE,    
   COUNT(1) OVER() AS RowCount_NUMB,    
   ROW_NUMBER() OVER ( ORDER BY ' + @Ls_OrderOfDisplay_TEXT + ', D.Case_IDNO, D.OrderSeq_NUMB, D.MajorIntSeq_NUMB, D.MinorIntSeq_NUMB ) AS Row_NUMB    
  FROM    
   DMNR_Y1 D    
   JOIN CASE_Y1 C    
    ON D.Case_IDNO = C.Case_IDNO    
   JOIN AMNR_Y1 M    
    ON D.ActivityMinor_CODE = M.ActivityMinor_CODE    
  WHERE     
   ' + @Ls_WorkerDelegate_TEXT + '    
   D.AlertPrior_DATE <=CONVERT(VARCHAR(10), @Ld_Current_DATE, 111)  AND    
   M.ActionAlert_CODE =  @Lc_ActionAlert_CODE  AND    
   M.EndValidity_DATE = CONVERT(VARCHAR(10), @Ld_High_DATE, 111)  AND    
   D.Status_DATE =  CONVERT(VARCHAR(10), @Ld_High_DATE, 111)  AND    
   D.Status_CODE =  @Lc_StatusStart_CODE  AND    
   D.Entered_DATE BETWEEN  CONVERT(VARCHAR(10), @Ad_From_DATE, 111)  AND  CONVERT(VARCHAR(10), @Ad_To_DATE, 111) ';    
    
 IF @An_Office_IDNO IS NOT NULL    
 BEGIN    
  IF @An_OfficeCentralExists_INDC != 1     
  BEGIN    
   SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +    
          ' AND C.County_IDNO =CONVERT(VARCHAR(3), @An_County_IDNO)';    
  END    
 END    
     
 IF @An_Case_IDNO IS NOT NULL    
 BEGIN    
  SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +    
         ' AND D.Case_IDNO = CONVERT(VARCHAR(6), @An_Case_IDNO) ';    
 END    
     
 IF @Ac_File_ID IS NOT NULL OR @Ac_TypeCase_CODE IS NOT NULL OR @Ac_RespondInit_CODE IS NOT NULL    
 BEGIN    
  SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +     
        ' AND EXISTS (    
            SELECT 1    
            FROM CASE_Y1 C1    
            WHERE     
             C1.Case_IDNO = D.Case_IDNO ';    
      
  IF @Ac_File_ID IS NOT NULL    
  BEGIN    
   SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +     
         ' AND C1.File_ID = @Ac_File_ID ';    
  END    
      
  IF @Ac_TypeCase_CODE IS NOT NULL    
  BEGIN    
   SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +     
         ' AND C1.TypeCase_CODE = @Ac_TypeCase_CODE ';    
  END    
      
  IF @Ac_RespondInit_CODE IS NOT NULL    
  BEGIN    
   SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +     
         ' AND C1.RespondInit_CODE =  @Ac_RespondInit_CODE ';    
  END    
      
  SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT + ' )';    
 END    
     
 IF @Ac_Category_CODE IS NOT NULL    
 BEGIN    
  SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +    
        ' AND D.Subsystem_CODE = @Ac_Category_CODE ';    
 END    
     
 IF @Ac_SubCategory_CODE IS NOT NULL    
 BEGIN    
  SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +    
        ' AND D.ActivityMajor_CODE =  @Ac_SubCategory_CODE ';    
 END    
     
 IF @Ac_ActivityMinor_CODE IS NOT NULL    
 BEGIN    
  SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +    
        ' AND D.ActivityMinor_CODE = @Ac_ActivityMinor_CODE ';    
 END    
     
 IF @Ac_DaysOverdue_QNTY IS NOT NULL    
 BEGIN    
  IF @Ac_DaysOverdue_QNTY = '1' OR @Ac_DaysOverdue_QNTY = '01'
  BEGIN    
   SET @Ls_DaysOverdue_TEXT = ' = 1 ';    
  END    
  ELSE IF @Ac_DaysOverdue_QNTY = '2' OR @Ac_DaysOverdue_QNTY = '02'
  BEGIN    
   SET @Ls_DaysOverdue_TEXT = ' BETWEEN 2 AND 10 ';    
  END    
  ELSE IF @Ac_DaysOverdue_QNTY = '11'    
  BEGIN    
   SET @Ls_DaysOverdue_TEXT = ' BETWEEN 11 AND 30 ';    
  END    
  ELSE IF @Ac_DaysOverdue_QNTY = '30'    
  BEGIN    
   SET @Ls_DaysOverdue_TEXT = ' BETWEEN 31 AND 60 ';    
  END    
  ELSE IF @Ac_DaysOverdue_QNTY = '60'    
  BEGIN    
   SET @Ls_DaysOverdue_TEXT = ' > 60 ';    
  END    
  ELSE IF @Ac_DaysOverdue_QNTY = 'S'    
  BEGIN    
   SET @Ls_DaysOverdue_TEXT = ' >= 1 ';    
  END    
  ELSE    
  BEGIN    
   SET @Ls_DaysOverdue_TEXT = @Lc_Empty_TEXT;    
  END    
      
  SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +     
        ' AND DATEDIFF(dd, D.Due_DATE, CONVERT(VARCHAR(10), @Ld_Current_DATE) )' + @Ls_DaysOverdue_TEXT;    
 END    
     
 SET @Ls_Alias_TEXT = ') A    
  WHERE     
   (    
    Row_NUMB BETWEEN  CONVERT(VARCHAR(10), @Ai_RowFrom_NUMB)  AND CONVERT(VARCHAR(10), @Ai_RowTo_NUMB)   
   )    
   OR    
   (    
    CONVERT(VARCHAR(10), @Ai_RowFrom_NUMB)  =  CONVERT(VARCHAR(1), @Li_Zero_NUMB ) AND CONVERT(VARCHAR(10), @Ai_RowTo_NUMB)  = CONVERT(VARCHAR(1), @Li_Zero_NUMB )     
   ) 
   )A
   )A
   ORDER BY ROW_NUMB';    
     
 SET @Ls_Query_TEXT = @Ls_WorkerList_TEXT +    
      @Ls_OuterSelect_TEXT +    
      @Ls_AssignedSelectDmnr_TEXT +    
      @Ls_WhereAppend_TEXT +    
      @Ls_Alias_TEXT; 
      
      PRINT @Ls_Query_TEXT;
        
    EXEC sp_executesql
     @Ls_Query_TEXT,
     @Ls_ParameterDefination_TEXT,
      @Ac_Worker_ID                       = @Ac_Worker_ID                         ,
 @An_Case_IDNO                       = @An_Case_IDNO                         ,
 @Ac_File_ID                         = @Ac_File_ID                           ,
 @An_Office_IDNO                     = @An_Office_IDNO                       ,
 @Ad_From_DATE                       = @Ad_From_DATE                         ,
 @Ad_To_DATE                         = @Ad_To_DATE                           ,
 @Ac_DaysOverdue_QNTY                = @Ac_DaysOverdue_QNTY                  ,
 @Ac_Category_CODE                   = @Ac_Category_CODE                     ,
 @Ac_SubCategory_CODE                = @Ac_SubCategory_CODE                  ,
 @Ac_ActivityMinor_CODE              = @Ac_ActivityMinor_CODE                ,
 @Ac_OrderOfDisplay_TEXT             = @Ac_OrderOfDisplay_TEXT               ,
 @Ac_TypeCase_CODE                   = @Ac_TypeCase_CODE                     ,
 @Ac_RespondInit_CODE                = @Ac_RespondInit_CODE                  ,
 @An_County_IDNO                     = @An_County_IDNO                       ,
 @An_OfficeCentralExists_INDC        = @An_OfficeCentralExists_INDC          ,
 @Ai_RecordLevel_NUMB                = @Ai_RecordLevel_NUMB                  ,
 @Ai_RowFrom_NUMB                    = @Ai_RowFrom_NUMB                      ,
 @Ai_RowTo_NUMB                      = @Ai_RowTo_NUMB                        ,
 @Ls_DaysOverdue_TEXT                =@Ls_DaysOverdue_TEXT,
 @Li_Zero_NUMB                       = @Li_Zero_NUMB                         ,
 @Li_One_NUMB                        = @Li_One_NUMB                          ,
 @Li_Two_NUMB                        = @Li_Two_NUMB                          ,
 @Li_Three_NUMB                      = @Li_Three_NUMB                        ,
 @Li_Four_NUMB                       = @Li_Four_NUMB                         ,
 @Lc_ActionAlert_CODE                = @Lc_ActionAlert_CODE                  ,
 @Lc_AlertStatusWarning_CODE         = @Lc_AlertStatusWarning_CODE           ,
 @Lc_AlertStatusFourOrMoreDays_CODE  = @Lc_AlertStatusFourOrMoreDays_CODE    ,
 @Lc_AlertStatusOverDueToWorker_CODE = @Lc_AlertStatusOverDueToWorker_CODE   ,  
 @Lc_AlertStatusDueToday_CODE        = @Lc_AlertStatusDueToday_CODE          ,
 @Lc_StatusStart_CODE                = @Lc_StatusStart_CODE                  ,
 @Lc_Empty_TEXT                      = @Lc_Empty_TEXT                        ,
 @Ld_Current_DATE                    = @Ld_Current_DATE                      ,
 @Ld_High_DATE                       = @Ld_High_DATE                         ;
    
    

   
END 

GO
