/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S120]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
*     PROCEDURE NAME    : DMNR_RETRIEVE_S120
*     DESCRIPTION       : Retrieves the Alert count based on functional area and Worker Name
*     DEVELOPED BY      : IMP Team
*     DEVELOPED ON      : 30-OCT-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S120](    
 @Ac_Worker_ID             CHAR(30),    
 @An_Case_IDNO             NUMERIC(6, 0),    
 @Ac_File_ID               CHAR(15),    
 @An_Office_IDNO           NUMERIC(3, 0),    
 @Ad_From_DATE             DATE,    
 @Ad_To_DATE               DATE,    
 @Ac_DaysOverdue_QNTY      CHAR(3),    
 @Ac_Category_CODE         CHAR(2),    
 @Ac_SubCategory_CODE      CHAR(4),    
 @Ac_ActivityMinor_CODE    CHAR(5),    
 @Ac_TypeCase_CODE         CHAR(1),    
 @Ac_RespondInit_CODE      CHAR(1),    
 @An_County_IDNO           NUMERIC(3, 0),    
 @An_OfficeCentralExists_INDC NUMERIC(2, 0),    
 @Ac_NextLevelWorker_ID   CHAR(30),    
 @Ai_RecordLevel_NUMB   INT    
)    
AS    
BEGIN    
 DECLARE    
        @Lc_Percentage_TEXT  CHAR(1) = '%',    
        @Lc_Hyphen_TEXT   CHAR(1) = '-',    
        @Lc_Empty_TEXT   CHAR(1) = '',    
        @Lc_ActionAlert_CODE CHAR(1) = 'A',    
        @Lc_TableCpro_ID  CHAR(4) = 'CPRO',    
        @Lc_TableSubCatg_ID  CHAR(4) = 'CATG',    
        @Lc_StatusStart_CODE CHAR(4) = 'STRT',    
        @Ld_Current_DATE  DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),    
        @Ld_High_DATE   DATE = '12/31/9999';    
     
 DECLARE    
        @Ls_DaysOverdue_TEXT VARCHAR(500) = '',    
        @Ls_Query_TEXT   NVARCHAR(MAX) = '',    
        @Ls_InnerSelect_TEXT NVARCHAR(MAX) = '',    
        @Ls_WhereAppend_TEXT NVARCHAR(MAX) = '',
        @Ls_ParameterDefination_TEXT  NVARCHAR(MAX)=' ';    
        
        SET @Ls_ParameterDefination_TEXT = 
      N'@Ac_Worker_ID             CHAR(30),    
 @An_Case_IDNO             NUMERIC(6, 0),    
 @Ac_File_ID               CHAR(15),    
 @An_Office_IDNO           NUMERIC(3, 0),    
 @Ad_From_DATE             DATE,    
 @Ad_To_DATE               DATE,    
 @Ac_DaysOverdue_QNTY      CHAR(3),    
 @Ac_Category_CODE         CHAR(2),    
 @Ac_SubCategory_CODE      CHAR(4),    
 @Ac_ActivityMinor_CODE    CHAR(5),    
 @Ac_TypeCase_CODE         CHAR(1),    
 @Ac_RespondInit_CODE      CHAR(1),    
 @An_County_IDNO           NUMERIC(3, 0),    
 @An_OfficeCentralExists_INDC NUMERIC(2, 0),    
 @Ac_NextLevelWorker_ID   CHAR(30),    
 @Ai_RecordLevel_NUMB   INT   ,
 @Ls_DaysOverdue_TEXT VARCHAR(500),
 @Lc_ActionAlert_CODE CHAR(1),
 @Lc_TableCpro_ID  CHAR(4),
 @Lc_TableSubCatg_ID  CHAR(4),
 @Lc_StatusStart_CODE CHAR(4),
  @Ld_Current_DATE  DATE,
  @Ld_High_DATE   DATE';
    
 SET @Ls_InnerSelect_TEXT =     
  'SELECT    
   D.Subsystem_CODE,    
   D.WorkerDelegate_ID,
   COUNT(1) AlertCount_QNTY     
  FROM    
   DMNR_Y1 D    
   JOIN CASE_Y1 C    
   ON D.Case_IDNO = C.Case_IDNO    
   JOIN AMNR_Y1 M    
   ON D.ActivityMinor_CODE = M.ActivityMinor_CODE    
  WHERE    
   D.WorkerDelegate_ID IN (SELECT distinct Worker_ID FROM WorkersList) AND    
   D.AlertPrior_DATE <=CONVERT(VARCHAR(10), @Ld_Current_DATE, 111)AND    
   M.ActionAlert_CODE = @Lc_ActionAlert_CODE AND    
   M.EndValidity_DATE = CONVERT(VARCHAR(10), @Ld_High_DATE, 111)  AND    
   D.Status_DATE = CONVERT(VARCHAR(10), @Ld_High_DATE, 111)  AND    
   D.Status_CODE =@Lc_StatusStart_CODE  AND    
   D.Entered_DATE BETWEEN @Ad_From_DATE AND  @Ad_To_DATE';    
    
 IF @An_Office_IDNO IS NOT NULL    
 BEGIN    
  IF @An_OfficeCentralExists_INDC != 1     
  BEGIN    
   SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +    
         ' AND C.County_IDNO =   @An_County_IDNO ';    
  END    
 END    
     
 IF @An_Case_IDNO IS NOT NULL    
 BEGIN    
  SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +    
         ' AND D.Case_IDNO =  @An_Case_IDNO';    
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
         ' AND C1.File_ID =  @Ac_File_ID ';    
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
        ' AND D.Subsystem_CODE =  @Ac_Category_CODE ';    
 END    
     
 IF @Ac_SubCategory_CODE IS NOT NULL    
 BEGIN    
  SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +    
        ' AND D.ActivityMajor_CODE =  @Ac_SubCategory_CODE ';    
 END    
     
 IF @Ac_ActivityMinor_CODE IS NOT NULL    
 BEGIN    
  SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +    
        ' AND D.ActivityMinor_CODE =  @Ac_ActivityMinor_CODE';    
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
        ' AND DATEDIFF(dd, D.Due_DATE, @Ld_Current_DATE) ' + @Ls_DaysOverdue_TEXT;    
 END    
     
   
   SET @Ls_Query_TEXT = 'WITH Usrl as    
  ( SELECT DISTINCT Worker_ID, Supervisor_ID  
      FROM USRL_Y1 F   
     WHERE F.EndValidity_DATE = @Ld_High_DATE    
       AND F.Expire_DATE = @Ld_High_DATE   
       AND F.Office_IDNO =  @An_County_IDNO
   )    
 ,    
 WorkersListTemp      
 AS (SELECT 1 RecordLevel_NUMB,  
      CAST(  @Ac_Worker_ID  AS CHAR(30)) Worker_ID,      
      CAST('''' AS CHAR(30)) Supervisor_ID,     
      0 AS Cycle_NUMB,      
        CAST(''.' +' CAST(@Ac_Worker_ID AS CHAR(30))' + '.'' AS VARCHAR(MAX)) AS RootPath_TEXT 
  UNION ALL      
  SELECT RecordLevel_NUMB + 1 RecordLevel_NUMB,  
      U2.Worker_ID,      
      U2.Supervisor_ID,      
      CASE      
          WHEN W.RootPath_TEXT LIKE ''%.'' + U2.Worker_ID + ''.%'' THEN 1      
       ELSE 0      
      END AS Cycle_NUMB,      
      W.RootPath_TEXT + U2.Worker_ID + ''.'' AS RootPath_TEXT  
    FROM Usrl U2      
      INNER JOIN WorkersListTemp W      
     ON U2.Supervisor_ID = W.Worker_ID      
   WHERE W.Cycle_NUMB = 0      
 ) ,
 WorkersList  as       
(select Distinct RecordLevel_NUMB,Worker_ID,
 Supervisor_ID
 FROM WorkersListTemp W         
 where Cycle_NUMB = 0 
 ) 
SELECT   W.Worker_ID, 
                   X.Subsystem_CODE, 
                   W.Supervisor_ID,
                   W.RecordLevel_NUMB, 
                   ISNULL(D.AlertCount_QNTY,0) AlertCount_QNTY,
                   0 SubordinateAlertCount_QNTY
          FROM     WorkersList AS W CROSS JOIN (SELECT R.Value_CODE AS Subsystem_CODE 
                                                               FROM   REFM_Y1 AS R 
                                                               WHERE  R.Table_ID =  @Lc_TableCpro_ID 
                                                                      AND R.TableSub_Id = @Lc_TableSubCatg_ID ) AS X 
                   LEFT OUTER JOIN
                   ( ' + @Ls_InnerSelect_TEXT + '    
					 ' + @Ls_WhereAppend_TEXT + ' 
                           GROUP BY D.WorkerDelegate_ID ,D.Subsystem_CODE) AS D 
                   ON W.Worker_ID = D.WorkerDelegate_ID 
                      AND X.Subsystem_CODE = D.Subsystem_CODE
                   ORDER BY W.RecordLevel_NUMB, W.Supervisor_ID, W.Worker_ID';
     
     


 
 EXEC SP_EXECUTESQL  
 @Ls_Query_TEXT,
 @Ls_ParameterDefination_TEXT, 
 @Ac_Worker_ID      = @Ac_Worker_ID,       
 @An_Case_IDNO       = @An_Case_IDNO,     
 @Ac_File_ID           = @Ac_File_ID,   
 @An_Office_IDNO    = @An_Office_IDNO,      
 @Ad_From_DATE        = @Ad_From_DATE,    
 @Ad_To_DATE         = @Ad_To_DATE,     
 @Ac_DaysOverdue_QNTY     = @Ac_DaysOverdue_QNTY,
 @Ac_Category_CODE        = @Ac_Category_CODE,
 @Ac_SubCategory_CODE     = @Ac_SubCategory_CODE,
 @Ac_ActivityMinor_CODE   = @Ac_ActivityMinor_CODE,
 @Ac_TypeCase_CODE        = @Ac_TypeCase_CODE,
 @Ac_RespondInit_CODE     = @Ac_RespondInit_CODE,
 @An_County_IDNO          = @An_County_IDNO,
 @An_OfficeCentralExists_INDC = @An_OfficeCentralExists_INDC,
 @Ac_NextLevelWorker_ID      = @Ac_NextLevelWorker_ID,
 @Ai_RecordLevel_NUMB   = @Ai_RecordLevel_NUMB,
 @Ls_DaysOverdue_TEXT =@Ls_DaysOverdue_TEXT,
 @Lc_ActionAlert_CODE =@Lc_ActionAlert_CODE,
 @Lc_TableCpro_ID =@Lc_TableCpro_ID,
 @Lc_TableSubCatg_ID  =@Lc_TableSubCatg_ID,
 @Lc_StatusStart_CODE =@Lc_StatusStart_CODE,
  @Ld_Current_DATE  =@Ld_Current_DATE,
  @Ld_High_DATE   =@Ld_High_DATE;
 
 
END 

GO
