/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S5]  
(    
 @Ac_Worker_ID     CHAR(30),    
 @An_Case_IDNO     NUMERIC(6, 0),    
 @Ac_File_ID      CHAR(15),    
 @An_Office_IDNO     NUMERIC(3),    
 @Ad_From_DATE     DATE,    
 @Ad_To_DATE      DATE,    
 @Ac_DaysOverdue_QNTY   CHAR(3),    
 @Ac_Category_CODE    CHAR(2),    
 @Ac_SubCategory_CODE   CHAR(4),    
 @Ac_ActivityMinor_CODE   CHAR(5),    
 @Ac_OrderOfDisplay_TEXT   CHAR(4),    
 @Ac_Status_CODE     CHAR(2),    
 @Ac_ActionAlert_CODE   CHAR(1),    
 @Ac_TypeCase_CODE    CHAR(1),    
 @Ac_RespondInit_CODE   CHAR(1),    
 @An_County_IDNO     NUMERIC(3, 0),    
 @An_OfficeCentralExists_INDC NUMERIC(2, 0),    
 @Ai_RowFrom_NUMB    INT,    
 @Ai_RowTo_NUMB     INT    
)    
AS    
/*  
 *     PROCEDURE NAME    : DMNR_RETRIEVE_S5    
 *     DESCRIPTION       : Retrieve all Minor Activity details that was Delegated to a Worker in a Ascending Due Date order.    
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 05-AUG-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
 */  
BEGIN    
 DECLARE    
  @Lc_StatusAssigned_CODE    CHAR(2) = 'AS',    
  @Lc_StatusSupervisorApproval_CODE CHAR(2) = 'SA',    
  @Lc_StatusActive_CODE    CHAR(2) = 'AC',    
  @Lc_WorkerReminder_CODE    CHAR(2) = 'WR',    
  @Lc_ActionAlertActive_CODE   CHAR(1) = 'A',    
  @Lc_ActionAlertInformational_CODE CHAR(1) = 'I',    
  @Lc_ActionAlert_CODE CHAR(1) = 'A',   
  @Lc_Space_TEXT      CHAR(1) = ' ',    
  @Lc_Empty_TEXT      CHAR(1) = '',    
  @Lc_StatusStart_CODE    CHAR(4) = 'STRT',    
  @Lc_ActivityMajorCase_CODE   CHAR(4) = 'CASE',    
  @Lc_RemedyStatusExempt_CODE   CHAR(4) = 'EXMT',  
  @Lc_ActivityMinorAdagr_CODE   CHAR(5) = 'ADAGR',  
  @Lc_CaseRelationshipActive_CODE  CHAR(1) = 'A',    
  @Lc_CaseRelationshipPutFather_CODE  CHAR(1) = 'P',    
  @Lc_CaseMemberStatusActive_CODE  CHAR(1) = 'A',    
  @Ld_Current_DATE     DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),    
  @Ld_High_DATE      DATE = '12/31/9999';    
      
 DECLARE    
  @Ls_ParameterDefination_TEXT   NVARCHAR(MAX) = ' ',  
  @Ls_OuterSelect_TEXT     VARCHAR(MAX) = ' ',    
  @Ls_ActiveSelectWorker_TEXT    VARCHAR(MAX) = ' ',    
  @Ls_AssignedSelectDmnr_TEXT    VARCHAR(MAX) = ' ',    
  @Ls_SupervisorAssignedSelectDmnr_TEXT VARCHAR(MAX) = ' ',    
  @Ls_WhereAppend_TEXT     VARCHAR(MAX) = ' ',    
  @Ls_WhereOffice_TEXT     VARCHAR(MAX) = ' ',    
  @Ls_DaysOverdue_TEXT     NVARCHAR(300) = ' ',    
  @Ls_Alias_TEXT       VARCHAR(MAX) = ' ',    
  @Ls_Query_TEXT       NVARCHAR(MAX) = ' ',      
  @Ls_DelegateWorker_TEXT     VARCHAR(100) = ' ',
  @Ld_BusinessPrior28_DATE     DATE;  
  
  
 SET @Ls_ParameterDefination_TEXT =   
  N'@Ac_Worker_ID      CHAR(30),  
  @An_Office_IDNO      NUMERIC(3),  
  @Ld_Current_DATE     DATE,    
  @Ld_High_DATE      DATE,  
  @Ac_ActionAlert_CODE    CHAR(1),  
  @Lc_StatusStart_CODE    CHAR(4),  
  @An_County_IDNO      NUMERIC(3, 0),  
  @An_Case_IDNO      NUMERIC(6, 0),  
  @Ac_File_ID       CHAR(15),  
  @Ac_TypeCase_CODE     CHAR(1),  
  @Ac_RespondInit_CODE    CHAR(1),  
  @Ac_Category_CODE     CHAR(2),  
  @Ac_SubCategory_CODE    CHAR(4),  
  @Ac_ActivityMinor_CODE    CHAR(5),  
  @Lc_WorkerReminder_CODE    CHAR(2),  
  @Lc_ActivityMajorCase_CODE   CHAR(4),  
  @Lc_RemedyStatusExempt_CODE   CHAR(4),  
  @Ad_From_DATE      DATE,  
  @Ad_To_DATE       DATE,  
  @Ls_DaysOverdue_TEXT    NVARCHAR(300),  
  @Ai_RowFrom_NUMB     INT,  
  @Ai_RowTo_NUMB      INT,  
  @Lc_CaseRelationshipActive_CODE  CHAR(1),  
  @Lc_CaseRelationshipPutFather_CODE CHAR(1),  
  @Lc_CaseMemberStatusActive_CODE  CHAR(1),  
  @Lc_Space_TEXT      CHAR(1),  
  @Lc_ActionAlertInformational_CODE CHAR(1),  
  @Lc_ActivityMinorAdagr_CODE   CHAR(5)';  
  
 IF @Ac_ActionAlert_CODE = @Lc_ActionAlertInformational_CODE    
 BEGIN  
  SET @Ld_BusinessPrior28_DATE = dbo.BATCH_COMMON$SF_CALCULATE_NTH_BDAY(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(), -28) ;
 END  
    
 SET @Ls_OuterSelect_TEXT =     
  'SELECT  
   J.ActivityMinor_CODE,  
   (  
		CASE WHEN J.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE  
		THEN  
				(  
				 SELECT D.ReasonStatus_CODE  
				   FROM DMNR_Y1 D  
				  WHERE D.ActivityMinorNext_CODE = J.ActivityMinor_CODE AND  
						D.MinorIntSeq_NUMB = J.MinorIntSeq_NUMB - 1 AND  
						D.MajorIntSeq_NUMB = J.MajorIntSeq_NUMB AND  
						D.Case_IDNO = J.Case_IDNO  
				)  
		END  
   ) ReasonStatus_CODE,  
   J.DescriptionActivity_TEXT,  
   J.Entered_DATE,  
   J.WorkerUpdate_ID,  
   J.Case_IDNO,  
   J.MemberMci_IDNO,  
   E.Last_NAME,  
   E.First_NAME,  
   E.Middle_NAME,  
   E.Suffix_NAME,  
   J.Worker_ID,  
   J.File_ID,  
   J.Status_CODE,  
   J.OrderSeq_NUMB,  
   J.MajorIntSEQ_NUMB,  
   J.MinorIntSeq_NUMB,  
   J.Forum_IDNO,  
   J.Topic_IDNO,  
   J.AlertPrior_DATE, 
   (CASE WHEN @Ac_ActionAlert_CODE = '''+ @Lc_ActionAlertInformational_CODE + ''' 
          AND J.Subsystem_CODE != @Lc_WorkerReminder_CODE  
         THEN 28+dbo.BATCH_COMMON$SF_CALCULATE_BUSINESS_DAYS(@Ld_Current_DATE,  J.AlertPrior_DATE , 1)  
         WHEN @Ac_ActionAlert_CODE = '''+ @Lc_ActionAlert_CODE + '''   
         THEN DATEDIFF( d, J.Due_DATE, @Ld_Current_DATE )  
   END) DaysOverdue_QNTY,  
   J.Due_DATE,  
   J.TransactionEventSeq_NUMB,    
   J.ActivityMajor_CODE,    
   X.OthpSource_IDNO,    
   X.TypeOthpSource_CODE,    
   J.Subsystem_CODE,    
   J.RowCount_NUMB    
   FROM   
   (  
   SELECT  
    Z.ActivityMinor_CODE,    
    Z.DescriptionActivity_TEXT,    
    Z.Entered_DATE,    
    Z.WorkerUpdate_ID,    
    Z.Case_IDNO,    
    Z.MemberMci_IDNO, 
    Z.Worker_ID,  
    Z.File_ID,     
    Z.Status_CODE,    
    Z.OrderSeq_NUMB,    
    Z.MajorIntSEQ_NUMB,    
    Z.MinorIntSeq_NUMB,    
    Z.Forum_IDNO,    
    Z.Topic_IDNO,    
    Z.Due_DATE,    
    Z.TransactionEventSeq_NUMB,    
    Z.ActivityMajor_CODE,    
    Z.Subsystem_CODE,    
    Z.AlertPrior_DATE,    
    Z.Row_NUMB,    
    Z.RowCount_NUMB    
   FROM  
   ( ';  
    
 SET @Ls_ActiveSelectWorker_TEXT =     
  'SELECT  
   D.ActivityMinor_CODE,    
   M.DescriptionActivity_TEXT,    
   D.Entered_DATE,    
   D.WorkerUpdate_ID,    
   D.Case_IDNO,    
   D.MemberMci_IDNO,
   C.Worker_ID,  
   C.File_ID,      
   D.Status_CODE,    
   D.OrderSeq_NUMB,    
   D.MajorIntSEQ_NUMB,    
   D.MinorIntSeq_NUMB,    
   D.Forum_IDNO,    
   D.Topic_IDNO,    
   D.Due_DATE,    
   D.TransactionEventSeq_NUMB,    
   D.ActivityMajor_CODE,    
   D.Subsystem_CODE,    
   D.AlertPrior_DATE,  
   COUNT(1) OVER() AS RowCount_NUMB,    
   ROW_NUMBER() OVER ( ORDER BY D.Due_DATE ' + @Ac_OrderOfDisplay_TEXT + ', D.Case_IDNO, D.OrderSeq_NUMB, D.MajorIntSEQ_NUMB, D.MinorIntSeq_NUMB ) AS Row_NUMB        
  FROM     
  (    
   SELECT DISTINCT     
    U.Role_ID     
   FROM    
    USRL_Y1 U    
   WHERE  
    @Ac_Worker_ID IN  (U.Worker_ID, U.WorkerSub_ID) AND    
    U.Office_IDNO = @An_Office_IDNO AND    
    U.Effective_DATE <= @Ld_Current_DATE AND    
    U.Expire_DATE >= @Ld_Current_DATE AND    
    U.EndValidity_DATE = @Ld_High_DATE    
  ) U    
  JOIN ACRL_Y1 A    
  ON U.Role_ID = A.Role_ID    
  JOIN DMNR_Y1 D    
  ON    
  (    
   A.Category_CODE = D.Subsystem_CODE AND    
   A.SubCategory_CODE = D.ActivityMajor_CODE AND    
   A.ActivityMinor_CODE = D.ActivityMinor_CODE    
  )    
  JOIN AMNR_Y1 M    
  ON M.ActivityMinor_CODE = A.ActivityMinor_CODE    
  JOIN CASE_Y1 C    
  ON D.Case_IDNO = C.Case_IDNO     
  WHERE    
   A.EndValidity_DATE = @Ld_High_DATE AND    
   M.ActionAlert_CODE = @Ac_ActionAlert_CODE AND    
   M.EndValidity_DATE = @Ld_High_DATE AND    
   D.AlertPrior_DATE <= @Ld_Current_DATE ';  
     
 SET @Ls_AssignedSelectDmnr_TEXT =     
  'SELECT  
   D.ActivityMinor_CODE,    
   M.DescriptionActivity_TEXT,    
   D.Entered_DATE,    
   D.WorkerUpdate_ID,    
   D.Case_IDNO,    
   D.MemberMci_IDNO, 
   C.Worker_ID,  
   C.File_ID,        
   D.Status_CODE,    
   D.OrderSeq_NUMB,    
   D.MajorIntSEQ_NUMB,    
   D.MinorIntSeq_NUMB,    
   D.Forum_IDNO,    
   D.Topic_IDNO,    
   D.Due_DATE,    
   D.TransactionEventSeq_NUMB,    
   D.ActivityMajor_CODE,    
   D.Subsystem_CODE,    
   D.AlertPrior_DATE,
   COUNT(1) OVER() AS RowCount_NUMB,    
   ROW_NUMBER() OVER ( ORDER BY D.Due_DATE ' + @Ac_OrderOfDisplay_TEXT + ', D.Case_IDNO, D.OrderSeq_NUMB, D.MajorIntSEQ_NUMB, D.MinorIntSeq_NUMB ) AS Row_NUMB        
  FROM    
   DMNR_Y1 D    
   JOIN AMNR_Y1 M    
   ON D.ActivityMinor_CODE = M.ActivityMinor_CODE    
   JOIN CASE_Y1 C    
   ON D.Case_IDNO = C.Case_IDNO      
   WHERE    
   D.WorkerDelegate_ID IN    
   (    
    SELECT  
     @Ac_Worker_ID  
    UNION ALL    
    SELECT  
     U.Worker_ID    
    FROM  
     USRL_Y1 U    
    WHERE    
     U.WorkerSub_ID = @Ac_Worker_ID AND    
     U.Office_IDNO = @An_Office_IDNO AND    
     U.Effective_DATE <= @Ld_Current_DATE AND    
     U.Expire_DATE >= @Ld_Current_DATE AND    
     U.EndValidity_DATE = @Ld_High_DATE  
   ) AND  
   D.AlertPrior_DATE <= @Ld_Current_DATE AND    
   M.ActionAlert_CODE = @Ac_ActionAlert_CODE AND    
   M.EndValidity_DATE = @Ld_High_DATE';  
    
 SET @Ls_SupervisorAssignedSelectDmnr_TEXT =     
  'SELECT  
   D.ActivityMinor_CODE,    
    M.DescriptionActivity_TEXT,    
    D.Entered_DATE,    
    D.WorkerUpdate_ID,    
    D.Case_IDNO,    
    D.MemberMci_IDNO, 
    C.Worker_ID,  
    C.File_ID,        
    D.Status_CODE,    
    D.OrderSeq_NUMB,    
    D.MajorIntSEQ_NUMB,    
    D.MinorIntSeq_NUMB,    
    D.Forum_IDNO,    
    D.Topic_IDNO,    
    D.Due_DATE,    
    D.TransactionEventSeq_NUMB,    
    D.ActivityMajor_CODE,    
    D.Subsystem_CODE,    
    D.AlertPrior_DATE,
    COUNT(1) OVER() AS RowCount_NUMB,    
    ROW_NUMBER() OVER ( ORDER BY D.Due_DATE ' + @Ac_OrderOfDisplay_TEXT + ', D.Case_IDNO, D.OrderSeq_NUMB, D.MajorIntSEQ_NUMB, D.MinorIntSeq_NUMB ) AS Row_NUMB        
   FROM    
   DMNR_Y1 D    
   JOIN AMNR_Y1 M    
   ON D.ActivityMinor_CODE = M.ActivityMinor_CODE    
   JOIN CASE_Y1 C    
   ON D.Case_IDNO = C.Case_IDNO      
   WHERE    
   D.WorkerDelegate_ID IN    
   (    
    SELECT DISTINCT  
     U.Worker_ID    
    FROM  
     USRL_Y1 U    
    WHERE    
     U.Supervisor_ID = @Ac_Worker_ID AND    
     U.Worker_ID != @Ac_Worker_ID AND    
     U.Effective_DATE <= @Ld_Current_DATE AND    
     U.Expire_DATE >= @Ld_Current_DATE AND    
     U.EndValidity_DATE = @Ld_High_DATE    
   ) AND    
   D.AlertPrior_DATE <= @Ld_Current_DATE AND    
   M.ActionAlert_CODE = @Ac_ActionAlert_CODE AND    
   M.EndValidity_DATE = @Ld_High_DATE ';    
     
 IF @Ac_ActionAlert_CODE = @Lc_ActionAlertActive_CODE    
 BEGIN    
  SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT    
   + ' AND D.Status_DATE = @Ld_High_DATE AND    
   D.Status_CODE = @Lc_StatusStart_CODE ';    
 END    
  
 IF @An_Office_IDNO IS NOT NULL  
 BEGIN    
  IF @An_OfficeCentralExists_INDC != 1     
  BEGIN    
   IF @Ac_Status_CODE IN(@Lc_StatusAssigned_CODE, @Lc_StatusSupervisorApproval_CODE)    
   BEGIN    
    SET @Ls_WhereOffice_TEXT = ' AND C.County_IDNO = @An_County_IDNO';    
   END    
   ELSE    
   BEGIN    
    SET @Ls_WhereOffice_TEXT = 'AND C.County_IDNO = @An_County_IDNO AND  
     C.Office_IDNO = @An_Office_IDNO ';    
   END  
  END  
 END  
     
 IF @An_Case_IDNO IS NOT NULL    
 BEGIN    
  SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +   
   ' AND D.Case_IDNO = @An_Case_IDNO ';    
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
    ' AND C1.RespondInit_CODE = @Ac_RespondInit_CODE ';    
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
   ' AND D.ActivityMajor_CODE = @Ac_SubCategory_CODE ';    
 END    
     
 IF @Ac_ActivityMinor_CODE IS NOT NULL    
 BEGIN    
  SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +    
   ' AND D.ActivityMinor_CODE = @Ac_ActivityMinor_CODE ';    
 END    
     
 IF @Ac_ActionAlert_CODE = @Lc_ActionAlertInformational_CODE    
 BEGIN    
  SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +    
   ' AND D.AlertPrior_DATE != @Ld_High_DATE    
   AND    
   (    
    D.Subsystem_CODE = @Lc_WorkerReminder_CODE OR      
    D.AlertPrior_DATE >= ''' + CAST(CAST(@Ld_BusinessPrior28_DATE AS DATE) AS VARCHAR(MAX))   + '''
   )    
   AND    
   (    
    D.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE OR    
    D.Status_CODE = @Lc_RemedyStatusExempt_CODE OR    
    (    
     D.ActivityMajor_CODE != @Lc_ActivityMajorCase_CODE AND    
     D.Status_DATE = @Ld_High_DATE    
    )  
   )';    
 END    
 ELSE IF @Ac_DaysOverdue_QNTY IS NOT NULL    
 BEGIN    
  IF @Ac_DaysOverdue_QNTY = '01' OR @Ac_DaysOverdue_QNTY = '1'
  BEGIN    
   SET @Ls_DaysOverdue_TEXT = ' = 1 ';
  END    
  ELSE IF @Ac_DaysOverdue_QNTY = '02' OR @Ac_DaysOverdue_QNTY = '2'
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
   ' AND DATEDIFF( dd, D.Due_DATE, @Ld_Current_DATE ) ' + @Ls_DaysOverdue_TEXT;  
 END    
     
 SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +    
  ' AND D.Entered_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE ';    
     
 SET @Ls_Alias_TEXT = ') Z    
  WHERE (( @Ai_RowFrom_NUMB = 0 ) OR (Row_NUMB BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB))    
  ) J    
  JOIN DMJR_Y1 X    
  ON    
  (    
   X.MajorIntSeq_NUMB = J.MajorIntSeq_NUMB AND  
   X.Case_IDNO = J.Case_IDNO    
  )    
  CROSS APPLY    
  (    
   SELECT    
    Y.Case_idno,    
    Y.Last_NAME,    
    Y.First_NAME,    
    Y.Middle_NAME,    
    Y.Suffix_NAME  
   FROM    
   (    
    SELECT    
     M.Case_idno,    
     D.Last_NAME,    
     D.First_NAME,    
     D.Middle_NAME,    
     D.Suffix_NAME,    
     RANK() OVER(PARTITION BY M.Case_IDNO ORDER BY D.Last_NAME) Rank_NUMB    
    FROM    
     CMEM_Y1 M    
     JOIN DEMO_Y1 D
     ON M.MemberMci_IDNO = D.MemberMci_IDNO     
    WHERE
		(
			J.MemberMci_IDNO != 0 AND
			M.MemberMci_IDNO = J.MemberMci_IDNO AND
			M.Case_idno = J.Case_IDNO 
		)
		OR
		(
			J.MemberMci_IDNO = 0 AND
			M.CaseRelationship_CODE IN (@Lc_CaseRelationshipActive_CODE, @Lc_CaseRelationshipPutFather_CODE ) AND
			M.Case_idno = J.Case_IDNO AND
			M.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
		)
   ) Y    
   WHERE Rank_NUMB = 1    
  ) E    
  ORDER BY J.Row_NUMB ';    
     
 IF @Ac_Status_CODE = @Lc_StatusAssigned_CODE    
 BEGIN    
  SET @Ls_Query_TEXT =   
   @Ls_OuterSelect_TEXT +     
   @Ls_AssignedSelectDmnr_TEXT +    
   @Ls_WhereAppend_TEXT +    
   @Ls_WhereOffice_TEXT +    
   @Ls_Alias_TEXT;    
 END    
     
 IF @Ac_Status_CODE = @Lc_StatusSupervisorApproval_CODE    
 BEGIN    
  SET @Ls_Query_TEXT =   
   @Ls_OuterSelect_TEXT +    
   @Ls_SupervisorAssignedSelectDmnr_TEXT +    
   @Ls_WhereAppend_TEXT +    
   @Ls_WhereOffice_TEXT +    
   @Ls_Alias_TEXT;    
 END    
     
 IF @Ac_Status_CODE = @Lc_StatusActive_CODE    
 BEGIN    
  SET @Ls_DelegateWorker_TEXT = ' AND D.WorkerDelegate_ID = @Lc_Space_TEXT ';    
  SET @Ls_Query_TEXT =   
   @Ls_OuterSelect_TEXT +    
   @Ls_ActiveSelectWorker_TEXT +    
   @Ls_DelegateWorker_TEXT +    
   @Ls_WhereAppend_TEXT +    
   @Ls_WhereOffice_TEXT +    
   @Ls_Alias_TEXT;    
 END  
    
 EXEC SP_EXECUTESQL  
  @Ls_Query_TEXT,  
  @Ls_ParameterDefination_TEXT,  
  @Ac_Worker_ID = @Ac_Worker_ID,  
  @An_Office_IDNO = @An_Office_IDNO,  
  @Ld_Current_DATE = @Ld_Current_DATE,   
  @Ld_High_DATE = @Ld_High_DATE,  
  @Ac_ActionAlert_CODE = @Ac_ActionAlert_CODE,  
  @Lc_StatusStart_CODE = @Lc_StatusStart_CODE,  
  @An_County_IDNO = @An_County_IDNO,  
  @An_Case_IDNO = @An_Case_IDNO,  
  @Ac_File_ID = @Ac_File_ID,  
  @Ac_TypeCase_CODE = @Ac_TypeCase_CODE,  
  @Ac_RespondInit_CODE = @Ac_RespondInit_CODE,  
  @Ac_Category_CODE = @Ac_Category_CODE,  
  @Ac_SubCategory_CODE = @Ac_SubCategory_CODE,  
  @Ac_ActivityMinor_CODE = @Ac_ActivityMinor_CODE,  
  @Lc_WorkerReminder_CODE = @Lc_WorkerReminder_CODE,  
  @Lc_ActivityMajorCase_CODE = @Lc_ActivityMajorCase_CODE,  
  @Lc_RemedyStatusExempt_CODE = @Lc_RemedyStatusExempt_CODE,  
  @Ad_From_DATE = @Ad_From_DATE,  
  @Ad_To_DATE = @Ad_To_DATE,  
  @Ls_DaysOverdue_TEXT = @Ls_DaysOverdue_TEXT,  
  @Ai_RowFrom_NUMB = @Ai_RowFrom_NUMB,  
  @Ai_RowTo_NUMB = @Ai_RowTo_NUMB,  
  @Lc_CaseRelationshipActive_CODE = @Lc_CaseRelationshipActive_CODE,  
  @Lc_CaseRelationshipPutFather_CODE = @Lc_CaseRelationshipPutFather_CODE,  
  @Lc_CaseMemberStatusActive_CODE = @Lc_CaseMemberStatusActive_CODE,  
  @Lc_Space_TEXT = @Lc_Space_TEXT,  
  @Lc_ActionAlertInformational_CODE = Lc_ActionAlertInformational_CODE,  
  @Lc_ActivityMinorAdagr_CODE = @Lc_ActivityMinorAdagr_CODE;  
END      

GO
