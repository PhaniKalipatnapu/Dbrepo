/****** Object:  StoredProcedure [dbo].[APDM_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[APDM_RETRIEVE_S10]  (
     @An_Application_IDNO			NUMERIC(15,0),
     @Ac_ApplicationStatus_CODE		CHAR(1),
     @Ac_Last_NAME					CHAR(20),
     @Ac_First_NAME					CHAR(16),
     @Ac_Middle_NAME				CHAR(20),
     @Ac_Suffix_NAME				CHAR(4),
     @An_MemberSsn_NUMB				NUMERIC(9,0),
     @Ad_Birth_DATE					DATE,
     @An_ResideCounty_IDNO			NUMERIC(3,0),
     @Ac_Aliases_INDC				CHAR(1)            ,
     @Ac_MaidenNames_INDC			CHAR(1)            ,
     @Ac_Names_INDC					CHAR(1)            ,
     @Ac_AppSsn_INDC				CHAR(1)            ,
     @Ai_RowFrom_NUMB				INT =1             ,
     @Ai_RowTo_NUMB					INT =10            
     )                                                 
AS

/*
 *     PROCEDURE NAME    : APDM_RETRIEVE_S10
 *     DESCRIPTION       : Retrieve Application ID, Date of Birth, Member Race, Member SSN, Members Residing County from Member Demographics at the time Application Received and type of Service, Application Date, Worker ID who created/modified this record, Status of the Application and Unique Sequence number from Case Member details at the time of Application Received for the given input.
 *     DEVELOPED BY      : Protech Solutions Inc
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN
         DECLARE    
               @Ld_High_DATE				DATE = '12/31/9999',
			   @Lc_CaseRelationshipD_CODE	CHAR(1) = 'D',
			   @Ls_SelectOuter_TEXT			VARCHAR (MAX) ='', 
			   @Ls_WhereOuter_TEXT			VARCHAR (MAX) ='',
			   @Ls_SelectDefault_TEXT		VARCHAR (MAX) ='',
			   @Ls_WhereDefault_TEXT		VARCHAR (MAX) ='',
			   @Ls_Where_TEXT				VARCHAR (MAX) ='',
			   @Ls_WhereMaiden_TEXT			VARCHAR (MAX) ='',
			   @Ls_WhereAlias_TEXT			VARCHAR (MAX) ='',
			   @Ls_Main_TEXT				VARCHAR (MAX) ='',
			   @Lc_ApplicationStatus_CODE	CHAR(1)		= 'F';
			   
				     
			     
		set @Ls_SelectOuter_TEXT = 
					'SELECT 
         X.Application_IDNO , 
         X.Application_DATE , 
         X.TransactionEventSeq_NUMB , 
         X.ApplicationStatus_CODE ,
         X.ServiceRequested_CODE ,
         X.Case_IDNO,
         X.MemberSsn_NUMB,
         X.Birth_DATE ,
         X.ResideCounty_IDNO,  
         X.Race_CODE ,
         X.Last_NAME,
		 X.First_NAME,
		 X.Middle_NAME,
		 X.Suffix_NAME,
		 X.Line1_ADDR,
		 X.Line2_ADDR,
		 X.City_ADDR,
		 X.State_ADDR,
		 X.Zip_ADDR, 
         X.RowCount_NUMB 
          
      FROM 
         (

            SELECT 
               Y.Application_IDNO,
               Y.Application_DATE,
               Y.TransactionEventSeq_NUMB,   
               Y.ServiceRequested_CODE, 
               Y.ApplicationStatus_CODE, 
               Y.Case_IDNO,  
               Y.MemberSsn_NUMB, 
               Y.Birth_DATE, 
               Y.ResideCounty_IDNO,  
               Y.Race_CODE,
               Y.Last_NAME,
			   Y.First_NAME,
			   Y.Middle_NAME,
			   Y.Suffix_NAME,
			   Y.Line1_ADDR,
			   Y.Line2_ADDR,
			   Y.City_ADDR,
			   Y.State_ADDR,
			   Y.Zip_ADDR, 
               Y.RowCount_NUMB, 
               Y.ORD_ROWNUM AS row_num
            FROM 
               (
                  SELECT 
                     Z.Application_IDNO, 
                     Z.Application_DATE, 
                     Z.TransactionEventSeq_NUMB,
                     Z.ServiceRequested_CODE,
                     Z.ApplicationStatus_CODE,
                     Z.Case_IDNO,
                     Z.MemberSsn_NUMB,
                     Z.Birth_DATE,  
                     Z.ResideCounty_IDNO, 
                     Z.Race_CODE,
                     Z.Last_NAME,
					 Z.First_NAME,
					 Z.Middle_NAME,
					 Z.Suffix_NAME,
					 Z.Line1_ADDR,
					 Z.Line2_ADDR,
					 Z.City_ADDR,
					 Z.State_ADDR,
					 Z.Zip_ADDR, 
                     Z.RowCount_NUMB, 
                     ROW_NUMBER() OVER(
                        ORDER BY Z.Application_IDNO DESC, Z.Application_DATE DESC) AS ORD_ROWNUM
                  FROM 
                     ( ';
                     
        SET @Ls_SelectDefault_TEXT =
                     'SELECT 
                           d.Application_IDNO, 
                           c.ServiceRequested_CODE , 
           				   c.Application_DATE, 
							d.Last_NAME,
							d.First_NAME,                           
                           d.Middle_NAME,
                           d.Suffix_NAME,
                           a.Line1_ADDR,
                           a.Line2_ADDR,
                           a.City_ADDR,
                           a.State_ADDR,
                           a.Zip_ADDR,
                           d.Birth_DATE, 
                           d.Race_CODE , 
                           d.MemberSsn_NUMB, 
                           c.County_IDNO AS ResideCounty_IDNO,
                           c.ApplicationStatus_CODE, 
                           c.TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB, 
                           COUNT(1) OVER() AS RowCount_NUMB, 
                           x.Case_IDNO
                        FROM 
                              APCS_Y1 c
                           		LEFT OUTER JOIN 
                           	  USEM_Y1 u
                           		ON (u.Worker_ID = c.WorkerUpdate_ID
                           			AND u.EndValidity_DATE = '''+ CONVERT(VARCHAR,@Ld_High_DATE,101) +''') 
                              LEFT OUTER JOIN CASE_Y1 x 
                              ON x.Application_IDNO = c.Application_IDNO, 
                           	  APDM_Y1 d 
                              LEFT OUTER JOIN 
                              APAH_Y1 a 
                              ON 
                                 d.Application_IDNO = a.Application_IDNO AND 
                                 d.MemberMci_IDNO = a.MemberMci_IDNO AND 
                                 a.TypeAddress_CODE = ''M'' AND 
                                 a.EndValidity_DATE = '''+ CONVERT(VARCHAR,@Ld_High_DATE,101) +'''
                              , 
                             APCM_Y1 e 
                           		WHERE (c.Application_IDNO = e.Application_IDNO AND 
                           			e.MemberMci_IDNO = d.MemberMci_IDNO AND
                           			e.Application_IDNO = d.Application_IDNO)AND'
                           
            SET @Ls_WhereDefault_TEXT = @Ls_WhereDefault_TEXT + 
			' 
			e.EndValidity_DATE = '''+ CONVERT(VARCHAR,@Ld_High_DATE,101) +'''  
			AND c.EndValidity_DATE = '''+ CONVERT(VARCHAR,@Ld_High_DATE,101) +'''  
            AND d.EndValidity_DATE = '''+ CONVERT(VARCHAR,@Ld_High_DATE,101) +''''    
                           
                           
        IF @Ac_ApplicationStatus_CODE = @Lc_ApplicationStatus_CODE
        BEGIN             
			SET @Ls_WhereDefault_TEXT = @Ls_WhereDefault_TEXT + 'AND e.CaseRelationship_CODE = ''D'''
			IF @An_MemberSsn_NUMB IS NULL
			BEGIN
				IF @Ad_Birth_DATE IS NOT NULL
				BEGIN
					SET @Ls_WhereDefault_TEXT = @Ls_WhereDefault_TEXT + ' AND d.Birth_DATE = '''+ CONVERT(VARCHAR,@Ad_Birth_DATE,101) +''''
				END;
				
				IF (
						(
							( @An_ResideCounty_IDNO IS NOT NULL OR @An_Application_IDNO IS NOT NULL
							)
						AND @Ac_Last_NAME IS NULL AND @Ad_Birth_DATE IS NULL
						) OR
						( @An_ResideCounty_IDNO IS NULL AND @An_Application_IDNO IS NULL AND 
						  @Ac_Last_NAME IS NULL AND @Ad_Birth_DATE IS NULL
						)
					)
				BEGIN
					SET @Ls_WhereDefault_TEXT = @Ls_WhereDefault_TEXT + 'AND d.Birth_DATE = 
							   (
								  SELECT  TOP 1 MIN(m.Birth_DATE)
								  FROM APDM_Y1 m
										JOIN
										APCM_Y1 n
									ON (m.Application_IDNO = n.Application_IDNO)
								  WHERE 
									 m.Application_IDNO = c.Application_IDNO AND                                    
									 m.EndValidity_DATE = '''+ CONVERT(VARCHAR,@Ld_High_DATE,101) +''' AND 
									 m.MemberMci_IDNO = n.MemberMci_IDNO AND 
									 m.EndValidity_DATE = '''+ CONVERT(VARCHAR,@Ld_High_DATE,101) +''' AND 
									 n.CaseRelationship_CODE = '''+@Lc_CaseRelationshipD_CODE+'''
							   )'
				END;
			
				IF (@Ac_Names_INDC = 'Y' OR @Ac_Aliases_INDC = 'Y' OR @Ac_MaidenNames_INDC = 'Y')
					AND ( @An_ResideCounty_IDNO IS NOT NULL OR @An_Application_IDNO IS NOT NULL)
				BEGIN
					IF @Ac_Names_INDC = 'Y'
					BEGIN
						IF @Ac_Last_NAME IS NOT NULL
						BEGIN
							SET @Ls_WhereDefault_TEXT = @Ls_WhereDefault_TEXT + ' AND d.Last_NAME LIKE '+'''%'+ RTRIM(REPLACE(@Ac_Last_NAME,'''','''''')) + '%'''
						END;
						
						IF @Ac_First_NAME IS NOT NULL
						BEGIN
							SET @Ls_WhereDefault_TEXT = @Ls_WhereDefault_TEXT + ' AND d.First_NAME LIKE '+'''%'+ RTRIM(REPLACE(@Ac_First_NAME,'''','''''')) + '%'''
						END;
						
						IF @Ac_Middle_NAME IS NOT NULL
						BEGIN
							SET @Ls_WhereDefault_TEXT = @Ls_WhereDefault_TEXT + ' AND d.Middle_NAME LIKE'+'''%'+ RTRIM(@Ac_Middle_NAME) + '%'''
						END;
									
						IF @Ac_Suffix_NAME IS NOT NULL
						BEGIN
							SET @Ls_WhereDefault_TEXT = @Ls_WhereDefault_TEXT + ' AND d.Suffix_NAME LIKE '+'''%'+ RTRIM(@Ac_Suffix_NAME) + '%'''
						END;
					END;
					
					IF @Ac_Aliases_INDC = 'Y'
					BEGIN
						IF @Ac_Last_NAME IS NOT NULL
						BEGIN
							SET @Ls_WhereDefault_TEXT = @Ls_WhereDefault_TEXT + ' AND d.LastAlias_NAME LIKE '+'''%'+ RTRIM(REPLACE(@Ac_Last_NAME,'''','''''')) + '%'''
						END;
						
						IF @Ac_First_NAME IS NOT NULL
						BEGIN
							SET @Ls_WhereDefault_TEXT = @Ls_WhereDefault_TEXT + ' AND d.FirstAlias_NAME LIKE '+'''%'+ RTRIM(REPLACE(@Ac_First_NAME,'''','''''')) + '%'''
						END;
						
						IF @Ac_Middle_NAME IS NOT NULL
						BEGIN
							SET @Ls_WhereDefault_TEXT = @Ls_WhereDefault_TEXT + ' AND d.MiddleAlias_NAME LIKE '+'''%'+ RTRIM(@Ac_Middle_NAME) + '%'''
						END;
									
						IF @Ac_Suffix_NAME IS NOT NULL
						BEGIN
							SET @Ls_WhereDefault_TEXT = @Ls_WhereDefault_TEXT + ' AND d.SuffixAlias_NAME LIKE '+'''%'+ RTRIM(@Ac_Suffix_NAME) + '%'''
						END;
					END;
					
					IF @Ac_MaidenNames_INDC = 'Y'
					BEGIN
						SET @Ls_WhereDefault_TEXT = @Ls_WhereDefault_TEXT + ' AND (CHARINDEX('''+RTRIM(@Ac_Last_NAME)+''', d.MotherMaiden_NAME) > 0 OR CHARINDEX('''+RTRIM(@Ac_First_NAME)+''', d.MotherMaiden_NAME) > 0)'
					END;
					
				 END;
					
				END;			
			
			END;
		
		ELSE
		BEGIN
			SET @Ls_WhereDefault_TEXT = @Ls_WhereDefault_TEXT + ' AND e.CaseRelationship_CODE = ''C'''
		END;
		
		                        
        IF @An_Application_IDNO IS NOT NULL OR @An_MemberSsn_NUMB IS NOT NULL
        BEGIN
			IF @An_Application_IDNO IS NOT NULL
			BEGIN
				SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' d.Application_IDNO = '+ CONVERT(VARCHAR,@An_Application_IDNO)
			END;
			ELSE
			BEGIN
				SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' d.MemberSsn_NUMB = '+ CONVERT(VARCHAR,@An_MemberSsn_NUMB)
			END;
		END;
		ELSE
		BEGIN
			IF @Ac_Names_INDC = 'Y'
			BEGIN
				IF @Ac_Last_NAME IS NOT NULL
				BEGIN
					
					IF @Ls_Where_TEXT != ''
					BEGIN
						SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND '
					END;
				
					SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' d.Last_NAME LIKE '+'''%'+ RTRIM(REPLACE(@Ac_Last_NAME,'''','''''')) + '%'''
					
				END;
				
				IF @Ac_First_NAME IS NOT NULL
				BEGIN
				
					IF @Ls_Where_TEXT != ''
					BEGIN
						SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND '
					END;
					
					SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' d.First_NAME LIKE '+'''%'+ RTRIM(REPLACE(@Ac_First_NAME,'''','''''')) + '%'''
				END;
				
				IF @Ac_Middle_NAME IS NOT NULL
				BEGIN
				
					IF @Ls_Where_TEXT != ''
					BEGIN
						SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND '
					END;
					
					SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' d.Middle_NAME LIKE '+'''%'+ RTRIM(@Ac_Middle_NAME) + '%'''
				END;
							
				IF @Ac_Suffix_NAME IS NOT NULL
				BEGIN
				
					IF @Ls_Where_TEXT != ''
					BEGIN
						SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND '
					END;
				
					SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' d.Suffix_NAME LIKE '+'''%'+ RTRIM(@Ac_Suffix_NAME) + '%'''
				END;
			END;
			
			IF @Ac_Aliases_INDC = 'Y'
			BEGIN
				IF @Ac_Last_NAME IS NOT NULL
				BEGIN
					SET @Ls_WhereAlias_TEXT = @Ls_WhereAlias_TEXT + ' d.LastAlias_NAME LIKE '+'''%'+ RTRIM(REPLACE(@Ac_Last_NAME,'''','''''')) + '%'''
				END;
				
				IF @Ac_First_NAME IS NOT NULL
				BEGIN
				
					IF @Ls_WhereAlias_TEXT != ''
					BEGIN
						SET @Ls_WhereAlias_TEXT = @Ls_WhereAlias_TEXT + ' AND '
					END;
				
					SET @Ls_WhereAlias_TEXT = @Ls_WhereAlias_TEXT + ' d.FirstAlias_NAME LIKE '+'''%'+ RTRIM(REPLACE(@Ac_First_NAME,'''','''''')) + '%'''
				END;
				
				IF @Ac_Middle_NAME IS NOT NULL
				BEGIN
				
					IF @Ls_WhereAlias_TEXT != ''
					BEGIN
						SET @Ls_WhereAlias_TEXT = @Ls_WhereAlias_TEXT + ' AND '
					END;
					
					SET @Ls_WhereAlias_TEXT = @Ls_WhereAlias_TEXT + ' d.MiddleAlias_NAME LIKE'+'''%'+ RTRIM(@Ac_Middle_NAME) + '%'''
				END;
							
				IF @Ac_Suffix_NAME IS NOT NULL
				BEGIN
									
					IF @Ls_WhereAlias_TEXT != ''
					BEGIN
						SET @Ls_WhereAlias_TEXT = @Ls_WhereAlias_TEXT + ' AND '
					END;
					
					SET @Ls_WhereAlias_TEXT = @Ls_WhereAlias_TEXT + ' d.SuffixAlias_NAME LIKE '+'''%'+ RTRIM(@Ac_Suffix_NAME) + '%'''
				END;
			END;
			
			IF @Ad_Birth_DATE IS NOT NULL
			BEGIN
			
				IF @Ls_Where_TEXT != ''
					BEGIN
						SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND '
					END;
					
				SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' d.Birth_DATE = '''+ CONVERT(VARCHAR,@Ad_Birth_DATE,101) +''''
			END;
			
		END; 
		
		IF @Ac_ApplicationStatus_CODE IS NOT NULL
		BEGIN
		
			IF @Ls_Where_TEXT != ''
				BEGIN
					SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND '
				END;
					
			SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' c.ApplicationStatus_CODE = '''+ @Ac_ApplicationStatus_CODE+''''
		END;
		
		IF @An_ResideCounty_IDNO IS NOT NULL
        BEGIN
        
			IF @Ls_Where_TEXT != ''
				BEGIN
					SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND '
				END;
					
			SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' c.County_IDNO = '+ CONVERT(VARCHAR,@An_ResideCounty_IDNO) +''
        END;
                           
        IF (@Ac_Names_INDC = 'N' AND @Ac_Aliases_INDC = 'N' AND @Ac_MaidenNames_INDC = 'N')
			OR @Ac_AppSsn_INDC = 'Y'
		BEGIN
			SET @Ls_Main_TEXT = @Ls_SelectDefault_TEXT +' ' +@Ls_Where_TEXT
			
			IF @Ls_Where_TEXT != ''
			BEGIN
				SET @Ls_Main_TEXT = @Ls_Main_TEXT + ' AND '
			END;
						
			SET @Ls_Main_TEXT = @Ls_Main_TEXT + ' ' + @Ls_WhereDefault_TEXT
		END;
		
		IF  @Ac_Names_INDC = 'Y' AND @Ac_AppSsn_INDC = 'N'
		BEGIN
			IF @Ls_Main_TEXT != ''
			BEGIN
				SET @Ls_Main_TEXT = @Ls_Main_TEXT + ' UNION ALL '
			END;
			
			SET @Ls_Main_TEXT = @Ls_Main_TEXT + @Ls_SelectDefault_TEXT +' '+ @Ls_Where_TEXT+ ' AND ' + @Ls_WhereDefault_TEXT
		END;
		
		IF @Ac_MaidenNames_INDC = 'Y' AND @Ac_AppSsn_INDC = 'N'
		BEGIN
			
			IF @Ls_Main_TEXT != ''
			BEGIN
				SET @Ls_Main_TEXT = @Ls_Main_TEXT + ' UNION ALL '
			END; 
			
			IF @Ac_MaidenNames_INDC = 'Y' AND @Ac_Last_NAME IS NOT NULL
			BEGIN
				SET @Ls_WhereMaiden_TEXT = @Ls_WhereMaiden_TEXT + ' (CHARINDEX('''+RTRIM(@Ac_Last_NAME)+''', RTRIM(d.MotherMaiden_NAME)) > 0 
					OR CHARINDEX('''+RTRIM(ISNULL(@Ac_First_NAME,''))+''', RTRIM(d.MotherMaiden_NAME)) > 0)'
			END;
			
			
			SET @Ls_Main_TEXT = @Ls_Main_TEXT + ' '+ @Ls_SelectDefault_TEXT + ' '+ @Ls_WhereMaiden_TEXT+' AND '+@Ls_WhereDefault_TEXT
			
        END; 
        
        IF  @Ac_Aliases_INDC = 'Y' AND @Ac_AppSsn_INDC = 'N'
		BEGIN
			IF @Ls_Main_TEXT != ''
			BEGIN
				SET @Ls_Main_TEXT = @Ls_Main_TEXT + ' UNION ALL '
			END;
			
			SET @Ls_Main_TEXT = @Ls_Main_TEXT + ' ' + @Ls_SelectDefault_TEXT +' '+ @Ls_WhereAlias_TEXT+ ' AND ' + @Ls_WhereDefault_TEXT
		END;               

                     
		SET @Ls_WhereOuter_TEXT =
					')  AS Z
               )  AS Y
            WHERE Y.ORD_ROWNUM <= '+CONVERT(VARCHAR,@Ai_RowTo_NUMB)+'

         )  AS X
      WHERE X.row_num >= '+CONVERT(VARCHAR,@Ai_RowFrom_NUMB)+'
ORDER BY ROW_NUM;';


EXEC (@Ls_SelectOuter_TEXT+' '+@Ls_Main_TEXT +' '+@Ls_WhereOuter_TEXT)
                     
                     
END; --End Of APDM_RETRIEVE_S10

GO
