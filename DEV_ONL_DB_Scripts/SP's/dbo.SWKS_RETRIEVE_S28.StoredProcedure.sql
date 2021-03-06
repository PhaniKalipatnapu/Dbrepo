/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S28]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S28] (    
 @An_Case_IDNO          NUMERIC(6, 0),    
 @An_OthpLocation_IDNO  NUMERIC(9, 0),    
 @Ac_Worker_ID          CHAR(30),    
 @Ac_ActivityMajor_CODE CHAR(4),    
 @Ac_ActivityMinor_CODE CHAR(5),    
 @Ac_TypeActivity_CODE  CHAR(1),    
 @Ad_From_DATE          DATE,    
 @Ad_To_DATE            DATE,    
 @Ac_ApptStatus_CODE    CHAR(2),    
 @An_Petition_IDNO      NUMERIC(7, 0),    
 @Ac_File_ID            CHAR(10),    
 @Ai_RowFrom_NUMB       INT =1,    
 @Ai_RowTo_NUMB         INT=10    
 )    
AS    
 /*                                                                                                                                                                                                                                               
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S28                                                                                                                                                                                                      
  *     DESCRIPTION       : Retrieve Schedule details for a Worker Idno that cannot be Empty, Schedule Date between From Date and To Date, Case Idno, Location Idno, Activity Type, Minor and Major Activity Code, and Appointment Status.        
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                                            
  *     DEVELOPED ON      : 08-SEP-2011                                                                                                                                                                                                           
  *     MODIFIED BY       :                                                                                                                                                                                                                       
  *     MODIFIED ON       :                                                                                                                                                                                                                       
  *     VERSION NO        : 1                                                                                                                                                                                                                     
 */    
 BEGIN    
  DECLARE @Lc_Space_TEXT                 CHAR(1) = ' ',    
          @Lc_ApptStatusCancelled_CODE   CHAR(2) = 'CN',    
          @Lc_ApptStatusCanForResch_CODE CHAR(2) = 'CR',    
          @Lc_ApptStatusConducted_CODE   CHAR(2) = 'CD',    
          @Lc_ApptStatusRescheduled_CODE CHAR(2) = 'RS',    
          @Lc_ApptStatusScheduled_CODE   CHAR(2) = 'SC',    
          @Lc_ActivityMinorAdmin_CODE    CHAR(5) = 'ADMIN',    
          @Lc_ActivityMinorPrsnl_CODE    CHAR(5) = 'PRSNL',    
          @Lc_ActivityMinorVactn_CODE    CHAR(5) = 'VACTN',    
          @Li_MinusOne_NUMB              SMALLINT = -1,    
          @Ld_High_DATE                  DATE = '12/31/9999',    
          @Li_Zero_NUMB                  SMALLINT = 0,    
          @Li_One_NUMB                   SMALLINT = 1,    
          @Lc_RelationCaseCp_CODE        CHAR (1) = 'C',    
          @Lc_RelationCaseNcp_CODE       CHAR (1) = 'A',    
          @Lc_RelationCasePutFather_CODE CHAR (1) = 'P',    
          @Lc_CloseBracket_CNST          CHAR (1) = ')',    
          @Lc_OpenBracket_CNST           CHAR (1) = '(',    
          @Lc_Slash_CNST                 CHAR (1) = '/',    
          @Lc_Semicolon_TEXT             CHAR (1) = ';',    
          @Lc_DescRelationCaseCp_CNST    CHAR (2) = 'CP',    
          @Lc_DescRelationCasePf_CNST    CHAR (2) = 'PF',    
          @Lc_DescRelationCaseDp_CNST    CHAR (3) = 'DEP',    
          @Lc_DescRelationCaseNcp_CNST   CHAR (3) = 'NCP',    
          @Lc_IdTableDprs_TEXT           CHAR (4) = 'DPRS',    
          @Lc_IdTableSubRole             CHAR (4) = 'ROLE',    
          @Ln_Member_IDNO           NUMERIC (10),    
          @Lc_Empty_TEXT                 CHAR (1) = '',    
          @Ls_Member_NAME                VARCHAR (65),    
          @Ls_CaseRelNjkidsFacts_CNST    VARCHAR (80),    
          @Lc_Comma_CNST                 CHAR(1) = ',',    
          @Lc_CdStatusNoticeT_CNST       CHAR(1) = 'T',    
          @Lc_WelfareTypeNive_CNST       CHAR(1) = 'F',    
          @Lc_WelfareTypeTanf_CNST       CHAR(1) = 'A';    
  DECLARE @Ls_OuterSelect_TEXT  VARCHAR(MAX) =' ',    
          @Ls_OuterSelect1_TEXT VARCHAR(MAX) =' ',    
          @Ls_OuterSelect2_TEXT VARCHAR(MAX) =' ',    
          @Ls_WhereAppend_TEXT  VARCHAR(MAX) = ' ',    
          @Ls_Alias_TEXT        VARCHAR(MAX) =' ',    
          @Ls_Query_TEXT                NVARCHAR(MAX) = ' ',  
          @Ls_ParameterDefination_TEXT  NVARCHAR(MAX)=' ';
    
    
     SET @Ls_ParameterDefination_TEXT =       
  N'@An_Case_IDNO          NUMERIC(6, 0),    
 @An_OthpLocation_IDNO  NUMERIC(9, 0),    
 @Ac_Worker_ID          CHAR(30),    
 @Ac_ActivityMajor_CODE CHAR(4),    
 @Ac_ActivityMinor_CODE CHAR(5),    
 @Ac_TypeActivity_CODE  CHAR(1),    
 @Ad_From_DATE          DATE,    
 @Ad_To_DATE            DATE,    
 @Ac_ApptStatus_CODE    CHAR(2),    
 @An_Petition_IDNO      NUMERIC(7, 0),    
 @Ac_File_ID            CHAR(10),
 @Lc_ApptStatusRescheduled_CODE CHAR(2),
 @Lc_ApptStatusScheduled_CODE CHAR(2),
 @Lc_ApptStatusCanForResch_CODE  CHAR(2),
 @Lc_ApptStatusCancelled_CODE CHAR(2),
 @Lc_ApptStatusConducted_CODE CHAR(2),
 @Lc_Space_TEXT                 CHAR(1),
 @Lc_ActivityMinorAdmin_CODE    CHAR(5) ,    
 @Lc_ActivityMinorPrsnl_CODE    CHAR(5),    
 @Lc_ActivityMinorVactn_CODE    CHAR(5)'; 
  
  
  
  IF @An_Case_IDNO IS NOT NULL    
   BEGIN    
    SET @Ls_WhereAppend_TEXT =@Ls_WhereAppend_TEXT + 'AND S.Case_IDNO =@An_Case_IDNO';    
   END    
    
  IF @An_OthpLocation_IDNO IS NOT NULL    
   BEGIN    
    SET @Ls_WhereAppend_TEXT =@Ls_WhereAppend_TEXT +@Lc_Space_TEXT+ 'AND S.OthpLocation_IDNO =@An_OthpLocation_IDNO';    
   END    
    
    IF @Ac_Worker_ID IS NOT NULL    
   BEGIN    
    SET @Ls_WhereAppend_TEXT =@Ls_WhereAppend_TEXT + @Lc_Space_TEXT+'AND S.Worker_ID = @Ac_Worker_ID';    
   END   
    
  IF @Ac_TypeActivity_CODE IS NOT NULL    
   BEGIN    
    SET @Ls_WhereAppend_TEXT =@Ls_WhereAppend_TEXT + @Lc_Space_TEXT+'AND S.TypeActivity_CODE =@Ac_TypeActivity_CODE';    
   END    
    
  IF @Ac_ActivityMinor_CODE IS NOT NULL    
   BEGIN    
    SET @Ls_WhereAppend_TEXT =@Ls_WhereAppend_TEXT +@Lc_Space_TEXT+ 'AND S.ActivityMinor_CODE  =@Ac_ActivityMinor_CODE';    
   END    
    
  IF @Ac_ActivityMajor_CODE IS NOT NULL    
   BEGIN    
    SET @Ls_WhereAppend_TEXT =@Ls_WhereAppend_TEXT +@Lc_Space_TEXT+ 'AND S.ActivityMajor_CODE  =@Ac_ActivityMajor_CODE';    
   END    
    
  IF @An_Petition_IDNO IS NOT NULL    
   BEGIN    
    SET @Ls_WhereAppend_TEXT =@Ls_WhereAppend_TEXT + @Lc_Space_TEXT+'AND F.Petition_IDNO=@An_Petition_IDNO';    
   END    
    
  IF @Ac_File_ID IS NOT NULL    
   BEGIN    
     SET @Ls_WhereAppend_TEXT=@Ls_WhereAppend_TEXT +@Lc_Space_TEXT+ 'AND (s.ActivityMajor_CODE NOT IN (SELECT S.ActivityMajor_CODE     
                       FROM SWKS_Y1 S     
                        JOIN    
                        DMNR_Y1 D    
                         ON (S.Case_IDNO=D.Case_IDNO    
                        AND s.Schedule_NUMB = D. Schedule_NUMB)    
                         JOIN    
                        FDEM_Y1 F    
                         ON ( F.Case_IDNO=D.Case_IDNO    
                          AND F. MajorIntSeq_NUMB = D. MajorIntSeq_NUMB)    
                        WHERE  S.CASE_IDNO= @An_Case_IDNO) OR (F.File_ID=@Ac_File_ID))'    
   END      
  IF @Ac_ApptStatus_CODE IS NOT NULL    
   BEGIN    
    IF @Ac_ApptStatus_CODE = @Lc_ApptStatusScheduled_CODE    
     BEGIN    
      SET @Ls_WhereAppend_TEXT =@Ls_WhereAppend_TEXT + @Lc_Space_TEXT+'AND S.ApptStatus_CODE IN (@Lc_ApptStatusRescheduled_CODE , @Lc_ApptStatusScheduled_CODE )'    
     END    
    
    IF @Ac_ApptStatus_CODE = @Lc_ApptStatusCancelled_CODE    
     BEGIN    
      SET @Ls_WhereAppend_TEXT =@Ls_WhereAppend_TEXT +@Lc_Space_TEXT+ 'AND S.ApptStatus_CODE IN ( @Lc_ApptStatusCanForResch_CODE , @Lc_ApptStatusCancelled_CODE )'    
     END    
    
    IF @Ac_ApptStatus_CODE = @Lc_ApptStatusConducted_CODE    
     BEGIN    
      SET @Ls_WhereAppend_TEXT =@Ls_WhereAppend_TEXT + @Lc_Space_TEXT+'AND S.ApptStatus_CODE = @Lc_ApptStatusConducted_CODE '    
     END    
   END 
     
    
 
  SET @Ls_Alias_TEXT ='    
     ) K     
     '+ CASE   WHEN @Ai_RowTo_NUMB = @Li_Zero_NUMB    
                                 THEN ''    
                                ELSE ' WHERE k.ORD_ROWNUM BETWEEN  ' + CONVERT(VARCHAR(10), @Ai_RowFrom_NUMB) + ' AND ' + CONVERT(VARCHAR(10), @Ai_RowTo_NUMB)    
                               END + '    
   ) T    
 OUTER APPLY (SELECT DISTINCT    
      RTRIM(CAST(A.CaseWelfare_IDNO AS CHAR(10))) +''' + @Lc_Comma_CNST + '''    
      FROM MHIS_Y1 AS A    
     WHERE A.Case_IDNO = T.Case_IDNO    
       AND A.TypeWelfare_CODE IN (''' + @Lc_WelfareTypeTanf_CNST + ''', ''' + @Lc_WelfareTypeNive_CNST + ''')    
       AND RTRIM(CAST(A.CaseWelfare_IDNO AS CHAR(10))) <> ''' + @Lc_Empty_TEXT + '''    
       AND A.CaseWelfare_IDNO IS NOT NULL    
       ORDER BY 1    
    FOR XML PATH('''')) AS O1 (IvaIveCases_TEXT)    
 OUTER APPLY (SELECT  ISNULL(N.Notice_ID, ''' + @Lc_Empty_TEXT + ''')     
        + ''' + @Lc_OpenBracket_CNST + '''     
        + ISNULL(N.DescriptionNotice_TEXT, ''' + @Lc_Empty_TEXT + ''')     
        + ''' + @Lc_CloseBracket_CNST + '''     
        + ''' + @Lc_Comma_CNST + '''     
      FROM NREF_Y1 N,    
        (SELECT DISTINCT    
          B.Notice_ID    
        FROM FORM_Y1 AS B,DMNR_Y1 D    
       WHERE B.Topic_IDNO=D.Topic_IDNO    
         AND D.Schedule_NUMB = T.Schedule_NUMB    
         AND D.Case_IDNO = T.Case_IDNO    
         AND NOT EXISTS (SELECT 1    
            FROM NMRQ_Y1    
           WHERE NMRQ_Y1.Barcode_NUMB = B.Barcode_NUMB    
             AND NMRQ_Y1.StatusNotice_CODE = ''' + @Lc_CdStatusNoticeT_CNST + ''')) B    
     WHERE N.Notice_ID = B.Notice_ID    
       AND N.EndValidity_DATE = ''' + CONVERT(VARCHAR(10), @Ld_High_DATE, 111) + '''    
    FOR XML PATH ('''')) AS O2 (Forms_TEXT)     
 OUTER APPLY (SELECT ISNULL(LTRIM(RTRIM(A.Last_NAME)), ''' + @Lc_Empty_TEXT + ''') + ''' + @Lc_Space_TEXT + '''     
      + ISNULL(LTRIM(RTRIM(A.Suffix_NAME)), ''' + @Lc_Empty_TEXT + ''') + ''' + @Lc_Space_TEXT + '''     
      + ISNULL(LTRIM(RTRIM(A.First_NAME)), ''' + @Lc_Empty_TEXT + ''') + ''' + @Lc_Space_TEXT + '''     
      + ISNULL(LTRIM(RTRIM(A.Middle_NAME)), ''' + @Lc_Empty_TEXT + ''')+''' + @Lc_Space_TEXT + '''    
      + ''' + @Lc_OpenBracket_CNST + ''' + CaseRelationship_TEXT      
      + ''' + @Lc_CloseBracket_CNST + ''' + '';''    
       FROM (SELECT A.Last_NAME,    
        A.Suffix_NAME,    
        A.First_NAME,    
        A.Middle_NAME,    
        M.MemberMci_IDNO,    
        C.File_ID,    
        ISNULL(CASE M.CaseRelationship_CODE            
          WHEN ''' + @Lc_RelationCaseCp_CODE + '''        
           THEN ''' + @Lc_DescRelationCaseCp_CNST + '''            
          WHEN ''' + @Lc_RelationCaseNcp_CODE + '''                                                                          
           THEN ''' + @Lc_DescRelationCaseNcp_CNST + '''            
          WHEN ''' + @Lc_RelationCasePutFather_CODE + '''            
           THEN ''' + @Lc_DescRelationCasePf_CNST + '''            
          ELSE ''' + @Lc_DescRelationCaseDp_CNST + '''            
            END, ''' + @Lc_Empty_TEXT + ''') CaseRelationship_TEXT    
         FROM DEMO_Y1 AS A,    
        CMEM_Y1 AS M,    
        CASE_Y1 AS C    
        WHERE M.MemberMci_IDNO IN(SELECT s.MemberMci_IDNO    
               FROM SWKS_Y1 s    
              WHERE s.Schedule_NUMB = T.Schedule_NUMB    
                AND s.MemberMci_IDNO != ''' + CONVERT(VARCHAR, @Li_Zero_NUMB) + ''')    
       AND A.MemberMci_IDNO = M.MemberMci_IDNO    
       AND M.Case_IDNO = T.Case_IDNO    
       AND C.Case_IDNO = T.Case_IDNO) A    
     FOR XML path ('''')) AS o3 (Member_TEXT)       
     ORDER BY ORD_ROWNUM ';    
  SET @Ls_OuterSelect_TEXT = 'SELECT     
          T.BeginSch_DTTM,            
                                  T.Schedule_DATE,            
                                  T.Case_IDNO,            
                                  ISNULL(T.Petition_IDNO,''' + CONVERT(VARCHAR(10), @Li_MinusOne_NUMB) + ''') Petition_IDNO,            
                                  ISNULL(T.File_ID,(SELECT TOP 1 f.File_ID    
                                    FROM FDEM_Y1  f      
                                    WHERE f.Case_IDNO = t.Case_IDNO    
               AND ( EXISTS ( SELECT 1     
                                    FROM FDEM_Y1  G    
                                    WHERE G.File_ID=f.File_ID    
                                     AND G.Petition_IDNO<>''' + CONVERT(VARCHAR,@Li_Zero_NUMB) + '''    
                                     AND G.EndValidity_DATE = ''' + CONVERT(VARCHAR(10),@Ld_High_DATE) + ''')     
                                      OR EXISTS ( SELECT 1     
                                          FROM FDEM_Y1 G     
                                        JOIN DCKT_Y1 A    
                                       ON     
                                      A.File_ID=G.File_ID    
                                        WHERE G.File_ID=f.File_ID    
                                         AND G.Petition_IDNO=''' + CONVERT(VARCHAR,@Li_Zero_NUMB) + '''    
                                         AND G.EndValidity_DATE = ''' + CONVERT(VARCHAR(10),@Ld_High_DATE) + ''')))) AS File_ID,            
                                  T.ApptStatus_CODE,            
                                  T.OthpLocation_IDNO,            
                                  (SELECT OtherParty_NAME            
                                  FROM OTHP_Y1 O            
                                  WHERE O.OtherParty_IDNO = T.OthpLocation_IDNO            
                                  AND O.TransactionEventSeq_NUMB = (SELECT MAX(O1.TransactionEventSeq_NUMB)    
                                                                      FROM OTHP_Y1 O1    
                                                                     WHERE O1.OtherParty_IDNO = T.OthpLocation_IDNO)) AS OtherParty_NAME,            
                                  SUBSTRING(IvaIveCases_TEXT,1,LEN(IvaIveCases_TEXT)-1) AS IvaIveCases_TEXT,    
                                  T.ActivityMajor_CODE,            
                                  (SELECT A.DescriptionActivity_TEXT            
                                     FROM AMNR_Y1 A            
                                    WHERE A.ActivityMinor_CODE = T.ActivityMinor_CODE            
                                      AND A.EndValidity_DATE = ''' + CONVERT(VARCHAR(10), @Ld_High_DATE, 111) + ''' ) AS DescriptionActivity_TEXT,            
                                  T.Worker_ID AS Worker_NAME,                     
                                  SUBSTRING(Member_TEXT,1,LEN(Member_TEXT)-1) AS Members_TEXT,            
                                  T.TypeActivity_CODE,            
                                  T.ActivityMinor_CODE,            
                                  T.Schedule_NUMB,            
                                  T.TransactionEventSeq_NUMB,            
                                  T.BeginValidity_DATE,            
                                  T.SchedulingUnit_CODE,            
                                  T.EndSch_DTTM,            
                                   SUBSTRING(Forms_TEXT,1,LEN(Forms_TEXT)-1) AS Forms_TEXT,            
                                  (SELECT N.DescriptionNote_TEXT            
                                     FROM NOTE_Y1 N             
                                    WHERE N.Case_IDNO = T.Case_IDNO            
                                      AND N.Topic_IDNO = T.Topic_IDNO            
                                      AND N.Post_IDNO = ''' + CONVERT(VARCHAR(10), @Li_One_NUMB) + '''           
                                      AND N.EndValidity_DATE = ''' + CONVERT(VARCHAR(10), @Ld_High_DATE, 111) + ''' ) AS Notes_TEXT,            
                                  T.RowCount_NUMB AS RowCount_NUMB            
                               FROM ( select k.* from ('    
  SET @Ls_OuterSelect2_TEXT= 'SELECT S.Schedule_NUMB,            
                                                    S.Case_IDNO,            
                                                    F.Petition_IDNO,    
                                                    F.File_ID,            
                                                  S.Schedule_DATE,            
                                                    S.BeginSch_DTTM,            
                                                    S.ActivityMinor_CODE,            
                                                    S.BeginValidity_DATE,            
                                                    S.ActivityMajor_CODE,            
                                                    S.OthpLocation_IDNO,      
             S.TypeActivity_CODE,            
                                                    S.Worker_ID  ,      
                                                    D.Topic_IDNO,            
                                                    S.ApptStatus_CODE,            
                                                    S.TransactionEventSeq_NUMB,            
                                                    S.SchedulingUnit_CODE,            
                                                    S.EndSch_DTTM,            
                                                    COUNT(1) OVER() AS RowCount_NUMB,            
                                                    ROW_NUMBER() OVER(ORDER BY S.Schedule_DATE,S.BeginSch_DTTM, S.Schedule_NUMB) AS ORD_ROWNUM            
                                               FROM SWKS_Y1 S            
                                                    JOIN DMNR_Y1 D            
                                                     ON ( s.Schedule_NUMB = D. Schedule_NUMB            
                                                            AND s.Case_IDNO = D.Case_IDNO)            
                                                    LEFT OUTER JOIN FDEM_Y1 F            
                                                     ON (F.Case_IDNO = D.Case_IDNO            
                                                         AND F. MajorIntSeq_NUMB = D. MajorIntSeq_NUMB            
                                                         )    
                                              WHERE S.Worker_ID !=  @Lc_Space_TEXT   AND           
                                              S.Schedule_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE            
                                              AND S.ActivityMinor_CODE NOT IN (@Lc_ActivityMinorAdmin_CODE ,@Lc_ActivityMinorPrsnl_CODE , @Lc_ActivityMinorVactn_CODE )';    
                                                  
  SET @Ls_Query_TEXT= @Ls_OuterSelect_TEXT + @Ls_OuterSelect2_TEXT + @Ls_WhereAppend_TEXT + @Ls_Alias_TEXT;    
    
exec sp_executesql 
 @Ls_Query_TEXT,
 @Ls_ParameterDefination_TEXT,
 @An_Case_IDNO                 =@An_Case_IDNO                  ,
 @An_OthpLocation_IDNO         =@An_OthpLocation_IDNO          ,
 @Ac_Worker_ID                 =@Ac_Worker_ID                  ,
 @Ac_ActivityMajor_CODE        =@Ac_ActivityMajor_CODE         ,
 @Ac_ActivityMinor_CODE        =@Ac_ActivityMinor_CODE         ,
 @Ac_TypeActivity_CODE         =@Ac_TypeActivity_CODE          ,
 @Ad_From_DATE                 =@Ad_From_DATE                  ,
 @Ad_To_DATE                   =@Ad_To_DATE                    ,
 @Ac_ApptStatus_CODE           =@Ac_ApptStatus_CODE            ,
 @An_Petition_IDNO             =@An_Petition_IDNO              ,
 @Ac_File_ID                   =@Ac_File_ID                    ,
 @Lc_ApptStatusRescheduled_CODE=@Lc_ApptStatusRescheduled_CODE ,
 @Lc_ApptStatusScheduled_CODE  =@Lc_ApptStatusScheduled_CODE   ,
 @Lc_ApptStatusCanForResch_CODE=@Lc_ApptStatusCanForResch_CODE ,  
 @Lc_ApptStatusCancelled_CODE  =@Lc_ApptStatusCancelled_CODE   ,  
 @Lc_ApptStatusConducted_CODE  =@Lc_ApptStatusConducted_CODE,
 @Lc_Space_TEXT=@Lc_Space_TEXT ,
 @Lc_ActivityMinorAdmin_CODE  =@Lc_ActivityMinorAdmin_CODE ,    
 @Lc_ActivityMinorPrsnl_CODE=@Lc_ActivityMinorPrsnl_CODE,    
 @Lc_ActivityMinorVactn_CODE  =@Lc_ActivityMinorVactn_CODE;     
  

 END; --END OF SWKS_RETRIEVE_S28                                                                                                                                                                                                                               
 
                                 
    
GO
