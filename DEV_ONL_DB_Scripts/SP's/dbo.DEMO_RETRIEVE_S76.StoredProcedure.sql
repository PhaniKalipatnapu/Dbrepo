/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S76]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S76] (  
 @Ac_First_NAME       VARCHAR(16) = NULL,  
 @Ac_Last_NAME        VARCHAR(20) = NULL,  
 @Ac_Middle_NAME      VARCHAR(20) = NULL,  
 @Ac_Suffix_NAME      VARCHAR(4) = NULL,  
 @An_MemberMci_IDNO   NUMERIC(10, 0) = NULL,  
 @An_MemberSsn_NUMB   NUMERIC(9, 0) = NULL,  
 @Ac_File_ID          VARCHAR(10) = NULL,  
 @Ad_Birth_DATE       DATE = NULL,  
 @Ai_AgeFrom_NUMB     INT = NULL,  
 @Ai_AgeTo_NUMB       INT = NULL,  
 @An_County_IDNO      NUMERIC(3, 0) = NULL,  
 @Ac_Race_CODE        CHAR(1) = NULL,  
 @Ac_MemberSex_CODE   CHAR(1) = NULL,  
 @Ac_Names_INDC       CHAR(1) = 'N',  
 @Ac_MaidenNames_INDC CHAR(1) = 'Y',  
 @Ac_AliasNames_INDC  CHAR(1) = 'N',  
 @Ai_RowFrom_NUMB     INT = 1,  
 @Ai_RowTo_NUMB       INT = 10  
 )  
AS  
 /*                              
 *     PROCEDURE NAME    : DEMO_RETRIEVE_S76                              
 *     DESCRIPTION       : Retrieve Active Enforcement details for a Case ID.                              
 *     DEVELOPED BY      : IMP Team                              
 *     DEVELOPED ON      : 02-NOV-2011                              
 *     MODIFIED BY       :                               
 *     MODIFIED ON       :                               
 *     VERSION NO        : 1                              
 */  
 BEGIN  
  SET NOCOUNT ON;  
  
  DECLARE @Lc_First_NAME            VARCHAR (15) = REPLACE(@Ac_First_NAME, '''', ''''''),  
          @Lc_Last_NAME             VARCHAR (20) = REPLACE(@Ac_Last_NAME, '''', ''''''),  
          @Lc_Middle_NAME           VARCHAR (20) = REPLACE(@Ac_Middle_NAME, '''', ''''''),  
          @Lc_Suffix_NAME           VARCHAR (4) = REPLACE(@Ac_Suffix_NAME, '''', ''''''),  
          @Lc_FirstAlias_NAME       VARCHAR (15) = NULL,  
          @Lc_Yes_INDC    CHAR(1)   = 'Y',  
          @Lc_No_INDC    CHAR(1)   = 'N',  
          @Ls_AgeCondition_TEXT  VARCHAR(MAX)  = '',  
          @Ls_Union_TEXT            VARCHAR (MAX) ='',  
          @Ls_InnerWhere_TEXT       VARCHAR (MAX) = '',  
          @Ls_InnerWhereEnd_TEXT    VARCHAR (MAX) = '',  
          @Ls_OuterJoin_TEXT        VARCHAR (MAX),  
          @Ls_OuterWhere_TEXT       VARCHAR (MAX),  
          @Ls_Where_TEXT            VARCHAR (MAX) = '',  
          @Ls_Relablity_TEXT        VARCHAR (MAX),  
          @Ls_Relablityfetch_TEXT       VARCHAR (MAX),  
          @Ls_OuterSelect_TEXT      VARCHAR (MAX),  
          @Lb_Conditon_TEXT         CHAR (1) = 'F',  
          @Ls_WhereName_TEXT           VARCHAR (MAX) = '',  
          @Ls_WhereOther_TEXT           VARCHAR (MAX) = '',  
          @Ls_WhereOtherName_TEXT           VARCHAR (MAX) = '',  
          @Ls_SelectName_TEXT       VARCHAR (MAX) = '',  
          @Ls_SelectMaiden_TEXT     VARCHAR (MAX) = '',  
          @Ls_SelectAlias_TEXT      VARCHAR (MAX) = '',  
          @Ls_NameTypeMatch_TEXT        VARCHAR(50),  
          @Ls_NameType_TEXT        VARCHAR(50),  
          @Ls_AliasNameType_TEXT        VARCHAR(50),  
          @Ls_MaidenNameType_TEXT        VARCHAR(50),  
          @Ls_Type_TEXT             VARCHAR(50),  
          @Ld_Current_DATE          DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),  
          @Ld_Low_DATE     DATE = '01/01/0001',  
          @Ls_ReliabilityCheck_TEXT VARCHAR(MAX) = '';  
  
  SET @Lc_First_NAME = RTRIM(LTRIM(@Lc_First_NAME));  
  SET @Lc_Last_NAME = RTRIM(LTRIM(@Lc_Last_NAME));  
  SET @Lc_Middle_NAME = RTRIM(LTRIM(@Lc_Middle_NAME));  
  SET @Lc_Suffix_NAME = RTRIM(LTRIM(@Lc_Suffix_NAME));  
  SET @Ac_File_ID = RTRIM(LTRIM(@Ac_File_ID));  
  SET @Ac_Race_CODE = RTRIM(LTRIM(@Ac_Race_CODE));  
  SET @Ac_MemberSex_CODE = RTRIM(LTRIM(@Ac_MemberSex_CODE));  
  SET @Ac_Names_INDC = RTRIM(LTRIM(@Ac_Names_INDC));  
  SET @Ac_MaidenNames_INDC = RTRIM(LTRIM(@Ac_MaidenNames_INDC));  
  SET @Ac_AliasNames_INDC = RTRIM(LTRIM(@Ac_AliasNames_INDC));  
  SET @Ls_NameTypeMatch_TEXT = ''''' Match_Type';  
  SET @Ls_NameType_TEXT = '''NAME'' Match_Type';  
  SET @Ls_AliasNameType_TEXT = '''ALIAS'' Match_Type';  
  SET @Ls_MaidenNameType_TEXT = '''MAIDEN'' Match_Type';  
  SET @Ls_AgeCondition_TEXT = ''''+@Lc_Yes_INDC+ ''' = ''' +@Lc_No_INDC +'''';  
   IF @An_MemberMci_IDNO IS NOT NULL  
   BEGIN  
    SET @Ls_ReliabilityCheck_TEXT = '';  
   END  
  ELSE  
   BEGIN  
    SET @Ls_ReliabilityCheck_TEXT = ' WHERE Reliability_PCT != ''0''';  
   END;  
  
 IF (@Ac_AliasNames_INDC = 'Y')  
   BEGIN  
    SET @Lc_FirstAlias_NAME = @Lc_First_NAME;  
   END;  
  
   IF (@Ad_Birth_DATE IS NOT NULL  
      OR @An_MemberSsn_NUMB IS NOT NULL)  
   BEGIN  
    SET @Lb_Conditon_TEXT = 'T';  
   END  
  
  IF @Ac_Names_INDC = 'Y'  
      OR @Ac_AliasNames_INDC = 'Y'  
      OR @Ac_MaidenNames_INDC = 'Y'  
   BEGIN  
    IF @Ac_Names_INDC = 'Y'  
     BEGIN  
      IF @Lb_Conditon_TEXT = 'T'  
       BEGIN  
        SET @Ls_WhereName_TEXT = @Ls_WhereName_TEXT + '(';  
       END;  
  
      SET @Ls_WhereName_TEXT = @Ls_WhereName_TEXT + '(((';  
      SET @Ls_WhereName_TEXT = @Ls_WhereName_TEXT + '(SOUNDEX(d.Last_NAME) like ' + 'SOUNDEX(''' + @Lc_Last_NAME + ''') OR d.Last_NAME like ''' + @Lc_Last_NAME + '%'')';  
        
   
      IF @Lc_First_NAME IS NOT NULL  
       BEGIN  
        SET @Ls_WhereName_TEXT = @Ls_WhereName_TEXT + ' OR (SOUNDEX(d.First_NAME) like ' + 'SOUNDEX(''' + @Lc_First_NAME + ''') OR d.First_NAME like ''' + @Lc_First_NAME + '%'')';  
       END;  
         
      SET @Ls_WhereName_TEXT = @Ls_WhereName_TEXT + ')';  
      IF @Lc_Middle_NAME IS NOT NULL  
       BEGIN  
        SET @Ls_WhereName_TEXT = @Ls_WhereName_TEXT + ' AND SOUNDEX(d.Middle_NAME) like ' + 'SOUNDEX(''' + @Lc_Middle_NAME + ''')';  
       END;  
      IF @Lc_Suffix_NAME IS NOT NULL  
       BEGIN  
        SET @Ls_WhereName_TEXT = @Ls_WhereName_TEXT + ' AND SOUNDEX(d.Suffix_NAME) like ' + 'SOUNDEX(''' + @Lc_Suffix_NAME + ''')';  
       END;  
         
      SET @Ls_WhereName_TEXT = @Ls_WhereName_TEXT + ')';  
        
      IF @Ad_Birth_DATE IS NOT NULL  
       BEGIN  
        SET @Ls_WhereName_TEXT = @Ls_WhereName_TEXT + ' OR d.Birth_DATE = ''' + CONVERT(VARCHAR, @Ad_Birth_DATE) + '''';  
        SET @Ls_AgeCondition_TEXT = ''''+@Lc_Yes_INDC+ ''' = ''' +@Lc_No_INDC +'''';  
       END;  
  
        IF @An_MemberSsn_NUMB IS NOT NULL  
       BEGIN  
        SET @Ls_WhereName_TEXT = @Ls_WhereName_TEXT + ' OR d.MemberSsn_NUMB = ''' + CONVERT(VARCHAR, @An_MemberSsn_NUMB) + '''';  
       END;   
       IF @Ad_Birth_DATE IS NOT NULL  
       OR @An_MemberSsn_NUMB IS NOT NULL  
       BEGIN  
          SET @Ls_WhereName_TEXT = @Ls_WhereName_TEXT + ')';   
       END  
            
       SET @Ls_WhereName_TEXT = @Ls_WhereName_TEXT + ')';   
        
     END;  
    IF @Ac_AliasNames_INDC = 'Y'  
     BEGIN  
      IF (@Lb_Conditon_TEXT = 'T' AND @Ac_Names_INDC = 'N')  
       BEGIN  
       SET @Ls_WhereOther_TEXT = @Ls_WhereOther_TEXT + '(';  
       END;  
  
      SET @Ls_WhereOther_TEXT = @Ls_WhereOther_TEXT + '(((';  
      SET @Ls_WhereOther_TEXT = @Ls_WhereOther_TEXT + '(SOUNDEX(AL.LastAlias_NAME) like ' + 'SOUNDEX(''' + @Lc_Last_NAME + ''') OR AL.LastAlias_NAME like ''' + @Lc_Last_NAME + '%'')';  
  
      IF @Lc_First_NAME IS NOT NULL  
       BEGIN  
        SET @Ls_WhereOther_TEXT = @Ls_WhereOther_TEXT + ' OR (SOUNDEX(AL.FirstAlias_NAME) like ' + 'SOUNDEX(''' + @Lc_First_NAME + ''') OR AL.FirstAlias_NAME like ''' + @Lc_First_NAME + '%'')';  
       END  
         
   SET @Ls_WhereOther_TEXT = @Ls_WhereOther_TEXT + ')';  
     
      IF @Lc_Middle_NAME IS NOT NULL  
       BEGIN  
        SET @Ls_WhereOther_TEXT = @Ls_WhereOther_TEXT + ' AND SOUNDEX(AL.MiddleAlias_NAME) like ' + 'SOUNDEX(''' + @Lc_Middle_NAME + ''')';  
       END  
  
      IF @Lc_Suffix_NAME IS NOT NULL  
       BEGIN  
        SET @Ls_WhereOther_TEXT = @Ls_WhereOther_TEXT + ' AND SOUNDEX(AL.SuffixAlias_NAME) like ' + 'SOUNDEX(''' + @Lc_Suffix_NAME + ''')';  
       END  
         
        SET @Ls_WhereOther_TEXT = @Ls_WhereOther_TEXT + ')';  
          
   IF (@Ac_Names_INDC = 'N')  
   BEGIN    
     IF @Ad_Birth_DATE IS NOT NULL  
       BEGIN  
        SET @Ls_WhereOther_TEXT = @Ls_WhereOther_TEXT + ' OR d.Birth_DATE = ''' + CONVERT(VARCHAR, @Ad_Birth_DATE) + '''';  
        SET @Ls_AgeCondition_TEXT = ''''+@Lc_Yes_INDC+ ''' = ''' +@Lc_No_INDC +''''  
       END  
         
    IF @An_MemberSsn_NUMB IS NOT NULL  
       BEGIN  
        SET @Ls_WhereOther_TEXT = @Ls_WhereOther_TEXT + ' OR d.MemberSsn_NUMB = ''' + CONVERT(VARCHAR, @An_MemberSsn_NUMB) + '''';  
       END;   
         
       IF @Ad_Birth_DATE IS NOT NULL  
       OR @An_MemberSsn_NUMB IS NOT NULL  
       BEGIN  
          SET @Ls_WhereOther_TEXT = @Ls_WhereOther_TEXT + ')';   
       END  
       END;          
       SET @Ls_WhereOther_TEXT = @Ls_WhereOther_TEXT + ')';  
     END;  
  
    IF @Ac_MaidenNames_INDC = 'Y'  
     BEGIN  
      IF (@Lb_Conditon_TEXT = 'T' AND @Ac_Names_INDC = 'N' AND @Ac_AliasNames_INDC = 'N')  
       BEGIN  
        SET @Ls_WhereOtherName_TEXT = @Ls_WhereOtherName_TEXT + '(';   
       END  
  SET @Ls_WhereOtherName_TEXT = @Ls_WhereOtherName_TEXT + '(((';   
      SET @Ls_WhereOtherName_TEXT = @Ls_WhereOtherName_TEXT + 'd.MotherMaiden_NAME like ' + '''%' + @Lc_Last_NAME + '%''';  
   
        SET @Ls_WhereOtherName_TEXT = @Ls_WhereOtherName_TEXT + ')';  
     
        SET @Ls_WhereOtherName_TEXT = @Ls_WhereOtherName_TEXT + ')';  
          
   IF (@Ac_Names_INDC = 'N'  
   AND @Ac_AliasNames_INDC = 'N')  
  BEGIN  
      IF @Ad_Birth_DATE IS NOT NULL  
       BEGIN  
        SET @Ls_WhereOtherName_TEXT = @Ls_WhereOtherName_TEXT + ' OR d.Birth_DATE = ''' + CONVERT(VARCHAR, @Ad_Birth_DATE) + '''';  
        SET @Ls_AgeCondition_TEXT = ''''+@Lc_Yes_INDC+ ''' = ''' +@Lc_No_INDC +''''  
       END  
         
     IF @An_MemberSsn_NUMB IS NOT NULL  
       BEGIN  
        SET @Ls_WhereOtherName_TEXT = @Ls_WhereOtherName_TEXT + ' OR d.MemberSsn_NUMB = ''' + CONVERT(VARCHAR, @An_MemberSsn_NUMB) + '''';  
          
       END;    
         
       IF @Ad_Birth_DATE IS NOT NULL  
       OR @An_MemberSsn_NUMB IS NOT NULL  
       BEGIN  
          SET @Ls_WhereOtherName_TEXT = @Ls_WhereOtherName_TEXT + ')';   
       END  
         
       END;  
  
         
       SET @Ls_WhereOtherName_TEXT = @Ls_WhereOtherName_TEXT + ')';  
       END   
   END  
  ELSE IF @Ac_Names_INDC = 'N'  
     AND @An_MemberMci_IDNO IS NOT NULL  
       
    BEGIN  
     SET @Ls_SelectName_TEXT = 'SELECT  
D.MemberMci_IDNO,   
D.Last_NAME ,  
D.First_NAME ,  
D.Middle_NAME ,      
D.Suffix_NAME,                             
D.Birth_DATE ,  
D.MemberSex_CODE ,  
D.Race_CODE,  
D.MemberSsn_NUMB,  
'''' as FirstAlias_NAME,  
D.IveParty_IDNO,';  
    IF @An_MemberMci_IDNO IS NOT NULL  
     BEGIN  
      SET @Ls_WhereName_TEXT = ' d.MemberMci_IDNO = ''' + CONVERT(VARCHAR, @An_MemberMci_IDNO) + '''';  
      SET @Ls_Type_TEXT = @Ls_NameTypeMatch_TEXT;  
     END  
      
   SET @Ls_Union_TEXT = @Ls_Union_TEXT + @Ls_SelectName_TEXT + @Ls_Type_TEXT + ' FROM DEMO_Y1 D                            
                               WHERE ' + ISNULL(@Ls_WhereName_TEXT, '');  
                               
   END;  
       
  
  IF ( @Ac_Race_CODE IS NOT NULL  
  OR @Ac_MemberSex_CODE IS NOT NULL  
  OR @Ac_File_ID IS NOT NULL  
  OR @An_County_IDNO IS NOT NULL)  
    
   BEGIN  
        
    IF @Ac_Race_CODE IS NOT NULL  
     BEGIN  
      SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND d.Race_CODE = ''' + @Ac_Race_CODE + '''';  
     END;  
  
    IF @Ac_MemberSex_CODE IS NOT NULL  
     BEGIN  
      SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND d.MemberSex_CODE = ''' + @Ac_MemberSex_CODE + '''';  
     END;  
     
   IF @Ac_File_ID IS NOT NULL  
   BEGIN  
    SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND D.MemberMci_IDNO in (Select MemberMci_IDNO                           
                                              from CMEM_Y1                           
                                             where Case_IDNO in (Select Case_IDNO                           
                                                                   from CASE_Y1                              
                                         Where File_ID = ''' + @Ac_File_ID + '''))';  
    END  
   IF @An_County_IDNO IS NOT NULL  
     BEGIN  
      SET @Ls_Where_TEXT =@Ls_Where_TEXT + ' AND ' + '''' + CONVERT(VARCHAR, @An_County_IDNO) + '''' + ' IN (SELECT C.County_IDNO FROM CMEM_Y1 CM                                     
                                                    JOIN CASE_Y1 C                                     
                                                    ON CM.Case_IDNO  = C.Case_IDNO                                    
                                                    WHERE CM.CaseMemberStatus_CODE = ''A''                                    
                                                    AND CM.MemberMci_IDNO = D.MemberMci_IDNO )';  
     END;  
     END; 

       IF @Ai_AgeFrom_NUMB IS NOT NULL  
       AND @Ai_AgeTo_NUMB IS NULL  
          BEGIN  
        SET @Ls_Where_TEXT = @Ls_Where_TEXT + 'AND (D.Birth_DATE <> ''' + CONVERT(VARCHAR(10),@Ld_Low_DATE,101) +''' AND DATEDIFF(YEAR,D.Birth_DATE, ''' + CONVERT(VARCHAR(10), @Ld_Current_DATE, 101) + ''') >= ' + CAST(@Ai_AgeFrom_NUMB AS CHAR)+')';  
        END;  
  
      IF @Ai_AgeTo_NUMB IS NOT NULL  
      AND @Ai_AgeFrom_NUMB IS NULL  
         BEGIN  
        SET @Ls_Where_TEXT = @Ls_Where_TEXT + 'AND (D.Birth_DATE <> ''' + CONVERT(VARCHAR(10),@Ld_Low_DATE,101) +''' AND DATEDIFF(YEAR,D.Birth_DATE, ''' + CONVERT(VARCHAR(10), @Ld_Current_DATE, 101) + ''') <= ' + CAST(@Ai_AgeTo_NUMB AS CHAR)+')';  
        END;  
  
      IF (@Ai_AgeFrom_NUMB IS NOT NULL  
          AND @Ai_AgeTo_NUMB IS NOT NULL)  
       BEGIN  
        SET @Ls_Where_TEXT = @Ls_Where_TEXT + 'AND (D.Birth_DATE <> ''' + CONVERT(VARCHAR(10),@Ld_Low_DATE,101) +''' AND DATEDIFF(YEAR,D.Birth_DATE, ''' + CONVERT(VARCHAR(10), @Ld_Current_DATE, 101) + ''') BETWEEN ' + CAST(@Ai_AgeFrom_NUMB AS CHAR) + 'AND ' + CAST (@Ai_AgeTo_NUMB AS CHAR)+')';  
       END;             
  
  SET @Ls_InnerWhere_TEXT = ' ) LO  
                                 ) LI';  
  SET @Ls_InnerWhereEnd_TEXT = ')  INS  
                         WHERE INS.[RowNumber] <= ' + CONVERT(VARCHAR, @Ai_RowTo_NUMB) + '                                    
                       ) OS                                    
                   WHERE OS.[RowNumber] >= ' + CONVERT(VARCHAR, @Ai_RowFrom_NUMB) + '                                    
                 ) JO ';  
  SET @Ls_OuterJoin_TEXT = ' JOIN  DEMO_Y1 DE                             
                                 ON JO.MemberMci_IDNO = DE.MemberMci_IDNO                 
                               LEFT OUTER JOIN  AHIS_Y1 AH                             
                                 ON (JO.MemberMci_IDNO = AH.MemberMci_IDNO                                    
                                 AND ISNULL(AH.TypeAddress_CODE,''M'')    =''M''                                    
                                AND ISNULL(AH.End_DATE,''12/31/9999'')  = ''12/31/9999''                                     
                                AND ISNULL(AH.Status_CODE,''Y'') = ''Y'' )                                    
                              ORDER BY JO.[RowNumber]';  
  SET @Ls_OuterWhere_TEXT = ' )  AS OS                                    
                                 WHERE OS.RowNumber >= ' + CONVERT(VARCHAR, @Ai_RowFrom_NUMB) + ' AND OS.RowNumber <= ' + CONVERT(VARCHAR, @Ai_RowTo_NUMB);  
  SET @Ls_Relablity_TEXT = ' dbo.BATCH_COMMON$SF_GET_PERCENT_RELIABILITY(';  
  
  BEGIN  
   IF (@Lc_Last_NAME IS NULL)  
    BEGIN  
     SET @Ls_Relablity_TEXT = @Ls_Relablity_TEXT + 'NULL,';  
    END  
   ELSE  
    BEGIN  
     SET @Ls_Relablity_TEXT = @Ls_Relablity_TEXT + '''' + @Lc_Last_NAME + ''',';  
    END  
  
   IF (@Lc_First_NAME IS NULL)  
    BEGIN  
     SET @Ls_Relablity_TEXT = @Ls_Relablity_TEXT + 'NULL,';  
    END  
   ELSE  
    BEGIN  
     SET @Ls_Relablity_TEXT = @Ls_Relablity_TEXT + '''' + @Lc_First_NAME + ''',';  
    END  
  
   IF (@Lc_Middle_NAME IS NULL)  
    BEGIN  
     SET @Ls_Relablity_TEXT = @Ls_Relablity_TEXT + 'NULL,';  
    END  
   ELSE  
    BEGIN  
     SET @Ls_Relablity_TEXT = @Ls_Relablity_TEXT + '''' + @Lc_Middle_NAME + ''',';  
    END  
  
   IF (@Lc_FirstAlias_NAME IS NULL)  
    BEGIN  
     SET @Ls_Relablity_TEXT = @Ls_Relablity_TEXT + 'NULL,';  
    END  
   ELSE  
    BEGIN  
     SET @Ls_Relablity_TEXT = @Ls_Relablity_TEXT + '''' + @Lc_FirstAlias_NAME + ''',';  
    END  
  
   IF (@Ad_Birth_DATE IS NULL)  
    BEGIN  
     SET @Ls_Relablity_TEXT = @Ls_Relablity_TEXT + 'NULL,';  
    END  
   ELSE  
    BEGIN  
     SET @Ls_Relablity_TEXT = @Ls_Relablity_TEXT + '''' + CONVERT(VARCHAR(10), @Ad_Birth_DATE, 101) + ''',';  
    END  
  
   IF (@Ac_MemberSex_CODE IS NULL)  
    BEGIN  
     SET @Ls_Relablity_TEXT = @Ls_Relablity_TEXT + 'NULL,';  
    END  
   ELSE  
    BEGIN  
     SET @Ls_Relablity_TEXT = @Ls_Relablity_TEXT + '''' + @Ac_MemberSex_CODE + ''',';  
    END  
  
   IF (@Ac_Race_CODE IS NULL)  
    BEGIN  
     SET @Ls_Relablity_TEXT = @Ls_Relablity_TEXT + 'NULL,';  
    END  
   ELSE  
    BEGIN  
     SET @Ls_Relablity_TEXT = @Ls_Relablity_TEXT + '''' + @Ac_Race_CODE + ''',';  
    END  
  
   IF (@An_MemberSsn_NUMB IS NULL)  
    BEGIN  
     SET @Ls_Relablity_TEXT = @Ls_Relablity_TEXT + 'NULL,';  
    END  
   ELSE  
    BEGIN  
     SET @Ls_Relablity_TEXT = @Ls_Relablity_TEXT + '''' + CONVERT(VARCHAR, @An_MemberSsn_NUMB) + ''',';  
    END  
  END  
  
  IF @An_MemberMci_IDNO IS NOT NULL  
   BEGIN  
    SET @Ls_Relablityfetch_TEXT = ''''' Reliability_PCT';  
   END  
  ELSE  
   BEGIN  
    SET @Ls_Relablityfetch_TEXT = 'JO.Reliability_PCT';  
   END  
  
  SET @Ls_OuterSelect_TEXT = '                                    
            SELECT   JO.MemberMci_IDNO,                          
                     JO.Match_Type ,                                    
                     DE.Last_NAME ,                                    
                     DE.First_NAME,                                    
                     DE.Middle_NAME, 
                     DE.Suffix_NAME,                                  
                     DE.Last_NAME                                  
                     + '' ''                                  
                     + DE.First_NAME                                  
                     + '' ''                                  
                     + DE.Middle_NAME FullDisplay_NAME,                                  
                     JO.Birth_DATE,                                     
                     JO.MemberSex_CODE ,                                     
                     JO.Race_CODE ,                                     
                     JO.MemberSsn_NUMB ,     
                     AH.Line1_ADDR,                                     
                     AH.Line2_ADDR,                                    
                     AH.City_ADDR ,                                     
                     AH.State_ADDR ,                                    
                     AH.Zip_ADDR,                                    
                     AH.Country_ADDR  ,                                  
                     AH.TypeAddress_CODE,                                    
                     ISNULL((SELECT TOP 1                                     
        C.Restricted_INDC FROM CASE_Y1 C                                     
         JOIN CMEM_Y1 CM                                     
          ON C.Case_IDNO = CM.Case_IDNO                                    
           WHERE  CM.MemberMci_IDNO = JO.MemberMci_IDNO                                    
            AND C.Restricted_INDC =''Y'' ),''N'') AS Restricted_INDC ,                                    
             ' + @Ls_Relablityfetch_TEXT + ',                          
             JO.IveParty_IDNO,                                   
             JO.[RowNumber],                                     
             JO.[RowCount_NUMB]                                    
              FROM                                      
               (                                        
      SELECT                                     
                 OS.MemberMci_IDNO,                                    
                 OS.Match_Type,                              
                 OS.Birth_DATE,                                     
                 OS.MemberSex_CODE,                                     
                 OS.Race_CODE ,                                     
                 OS.MemberSsn_NUMB ,                                    
                 OS.Reliability_PCT,                                  
                 OS.IveParty_IDNO,                                    
                 OS.[RowNumber],                                     
                 OS.[RowCount_NUMB]                                    
                FROM                     
                 (                                     
         SELECT                                     
                   INS.MemberMci_IDNO,                                    
                   INS.Match_Type ,                                    
                                        INS.Birth_DATE ,                 
                                        INS.MemberSex_CODE ,                                    
                                        INS.Race_CODE ,              
                                        INS.MemberSsn_NUMB ,                                    
                                        INS.Reliability_PCT,                                  
                                        INS.IveParty_IDNO,                                    
                                        INS.[RowNumber],                                     
                                        INS.[RowCount_NUMB]                                 
                  FROM                                     
                   (             
                    SELECT             
                     LI.MemberMci_IDNO,         
                     LI.Match_Type ,             
                     LI.Birth_DATE ,             
                     LI.MemberSex_CODE ,             
                     LI.Race_CODE ,             
                     LI.MemberSsn_NUMB ,   
                     CASE WHEN LI.Reliability_PCT < 0 then ''0'' Else CONVERT(VARCHAR,LI.Reliability_PCT) END Reliability_PCT ,             
                     LI.IveParty_IDNO,             
                     ROW_NUMBER() OVER( ORDER BY LI.Reliability_PCT DESC) AS [RowNumber] ,             
                     COUNT (1) OVER () [RowCount_NUMB]             
                     FROM   
                      (   
                       SELECT   
                       LO.MemberMci_IDNO,   
                       LO.Match_Type ,   
                       LO.Birth_DATE ,   
                       LO.MemberSex_CODE ,   
                       LO.Race_CODE ,   
                       LO.MemberSsn_NUMB,   
                       LO.FirstAlias_NAME, ' + @Ls_Relablity_TEXT + '   
                       LO.Last_NAME ,             
                       LO.First_NAME,             
                       LO.Middle_NAME ,                                
                       LO.FirstAlias_NAME,                                
                       LO.Birth_DATE,                                
                       LO.MemberSex_CODE,                                
                       LO.Race_CODE ,                                 
                       LO.MemberSsn_NUMB) as Reliability_PCT,   
                       LO.IveParty_IDNO                                    
                        FROM                                    
                         (  ';  
  
    SET @Ls_SelectName_TEXT = 'SELECT  
D.MemberMci_IDNO,   
D.Last_NAME ,  
D.First_NAME ,  
D.Middle_NAME ,  
D.Suffix_NAME,                                 
D.Birth_DATE ,  
D.MemberSex_CODE ,  
D.Race_CODE,  
D.MemberSsn_NUMB,  
'''' as FirstAlias_NAME,  
D.IveParty_IDNO,';  
  IF @Ac_Names_INDC = 'Y'  
   BEGIN  
   IF @Ls_Where_TEXT = ''   
    SET @Ls_Union_TEXT = @Ls_Union_TEXT + @Ls_SelectName_TEXT + @Ls_NameType_TEXT + ' FROM DEMO_Y1 D                            
                               WHERE ' + ISNULL(@Ls_WhereName_TEXT, ' 1=1 ')  
   ELSE  
   SET @Ls_Union_TEXT = @Ls_Union_TEXT + @Ls_SelectName_TEXT + @Ls_NameType_TEXT + ' FROM DEMO_Y1 D                            
                               WHERE ' + ' (' + @Ls_WhereName_TEXT + ISNULL(@Ls_Where_TEXT,' 1=1 ') + ')';  
END;  
  
  SET @Lc_Last_NAME = ISNULL(@Lc_Last_NAME, '''''');  
  
  IF @Ac_MaidenNames_INDC = 'Y'  
   BEGIN  
    SET @Ls_SelectMaiden_TEXT = 'SELECT  
D.MemberMci_IDNO,   
D.MotherMaiden_NAME Last_NAME,  
D.First_NAME ,  
D.Middle_NAME , 
D.Suffix_NAME,  
D.Birth_DATE ,  
D.MemberSex_CODE ,  
D.Race_CODE,  
D.MemberSsn_NUMB,  
'''' as FirstAlias_NAME,  
D.IveParty_IDNO,';  
  
    IF ISNULL(@Ls_Union_TEXT, '') != ''  
     SET @Ls_Union_TEXT = @Ls_Union_TEXT + ' UNION ALL ';  
     IF @Ls_Where_TEXT = ''  
     SET @Ls_Union_TEXT = @Ls_Union_TEXT + @Ls_SelectMaiden_TEXT + @Ls_MaidenNameType_TEXT + ' FROM DEMO_Y1 D                                      
                                WHERE ' + ISNULL(@Ls_WhereOtherName_TEXT, '')  
 ELSE  
    SET @Ls_Union_TEXT = @Ls_Union_TEXT + @Ls_SelectMaiden_TEXT + @Ls_MaidenNameType_TEXT + ' FROM DEMO_Y1 D                                      
                                WHERE ' +  ' (' + @Ls_WhereOtherName_TEXT  + @Ls_Where_TEXT + ')';  
   END  
  
  IF @Ac_AliasNames_INDC = 'Y'  
   BEGIN  
    SET @Ls_SelectAlias_TEXT = 'SELECT  
D.MemberMci_IDNO,   
AL.LastAlias_NAME Last_NAME,  
AL.FirstAlias_NAME First_NAME,  
D.Middle_NAME , 
D.Suffix_NAME,  
D.Birth_DATE ,  
D.MemberSex_CODE ,  
D.Race_CODE,  
D.MemberSsn_NUMB,  
'''' as FirstAlias_NAME,  
D.IveParty_IDNO,';  
  
    IF ISNULL(@Ls_Union_TEXT, '') != ''  
     SET @Ls_Union_TEXT = @Ls_Union_TEXT + ' UNION ALL ';  
     IF @Ls_Where_TEXT = ''  
      SET @Ls_Union_TEXT = @Ls_Union_TEXT + @Ls_SelectAlias_TEXT + @Ls_AliasNameType_TEXT + ' FROM DEMO_Y1 D LEFT OUTER JOIN  AKAX_Y1 AL  
                                  ON D.MemberMci_IDNO = AL.MemberMci_IDNO   
                               WHERE ' + ISNULL(@Ls_WhereOther_TEXT, '')  
 ELSE  
    SET @Ls_Union_TEXT = @Ls_Union_TEXT + @Ls_SelectAlias_TEXT + @Ls_AliasNameType_TEXT + ' FROM DEMO_Y1 D LEFT OUTER JOIN  AKAX_Y1 AL  
                                  ON D.MemberMci_IDNO = AL.MemberMci_IDNO   
                               WHERE ' + '(' + @Ls_WhereOther_TEXT + @Ls_Where_TEXT+ ')';  
   END;  

 EXEC ( @Ls_OuterSelect_TEXT + @Ls_Union_TEXT + @Ls_InnerWhere_TEXT + @Ls_ReliabilityCheck_TEXT + @Ls_InnerWhereEnd_TEXT + @Ls_OuterJoin_TEXT );  
 
 END; -- End Of DEMO_RETRIEVE_S76.  
  
GO
