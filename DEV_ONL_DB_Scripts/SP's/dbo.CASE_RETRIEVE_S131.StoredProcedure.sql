/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S131]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S131] (
 @Ac_First_NAME                CHAR(16) = NULL,
 @Ac_Last_NAME                 CHAR(20) = NULL,
 @Ac_SearchOptionLastName_CODE CHAR(1) = 'C',
 @An_Case_IDNO                 NUMERIC(6, 0) = NULL,
 @An_CaseWelfare_IDNO          NUMERIC(10, 0) = NULL,
 @Ac_File_ID                   CHAR(10) = NULL,
 @An_MemberMci_IDNO            NUMERIC(10, 0) = NULL,
 @An_MemberSsn_NUMB            NUMERIC(9, 0) = NULL,
 @Ad_Birth_DATE                DATE = NULL,
 @An_County_IDNO               NUMERIC(3, 0) = NULL,
 @Ac_SearchOption_CODE         CHAR(1) = '',
 @Ai_RowFrom_NUMB              INT = 1,
 @Ai_RowTo_NUMB                INT = 10
 )
AS
 /*                                                                                                                                                                                                               
  *     PROCEDURE NAME    : CASE_RETRIEVE_S131                                                                                                                                                             
  *     DESCRIPTION       : Retrieve CP/NCP Case Member details for a County, File Indo, Case Idno, Birth date, First Name, 
                            Last Name,  Member Idno and IV-A Case ID member where relationship is Custodial Parent for CP Case Member 
                            and Non Custodial Parent for NCP Case Member.                                                                                                                 
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                             
  *     DEVELOPED ON      : 16-AUG-2011                                                                                                                                                                            
  *     MODIFIED BY       :                                                                                                                                                                                        
  *     MODIFIED ON       :                                                                                                                                                                                        
  *     VERSION NO        : 1                                                                                                                                                                                      
 */
 BEGIN
  CREATE TABLE #SearchResult_P1
   (
     Case_IDNO      VARCHAR(6),
     MemberMci_IDNO NUMERIC(10),
     Rownum_NUMB    INT,
     RowCount_NUMB  INT
   );

  DECLARE @Lc_SearchOptionCp_CODE            CHAR(1) = 'C',
          @Lc_SearchOptionNcp_CODE           CHAR(1) = 'A',
          @Lc_SearchOptionDp_CODE            CHAR(1) = 'D',
          @Lc_LastNameOptionExact_CODE       CHAR(1) = 'E',
          @Lc_LastNameOptionStart_CODE       CHAR(1) = 'S',
          @Lc_LastNameOptionLike_CODE        CHAR(1) = 'L',
          @Lc_LastNameOptionSounds_CODE      CHAR(1) = 'D',
          @Lc_LastNameOptionContains_CODE    CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A',
          @Lc_CaseRelationshipCp_CODE        CHAR(1) = 'C',
          @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Ld_High_DATE                      DATE = '12/31/9999';
  DECLARE @Ls_FullSelect_TEXT  VARCHAR(MAX) = '',
          @Ls_MiddleWhere_TEXT VARCHAR(MAX) = ') AND  C1.CaseMemberStatus_CODE = ''A'' AND  C1.CaseRelationship_CODE IN ( ''A'',''P'')) AS V   )  AS MI                                                                                                                                             
                           WHERE 
                           	  MI.Rownum_NUMB <= ' + CONVERT(VARCHAR, @Ai_RowTo_NUMB),
          @Ls_OuterWhere_TEXT  VARCHAR(MAX) = ' )  AS OS                                                                                                                                                      
                         WHERE 
                         	OS.Rownum_NUMB >= ' + CONVERT(VARCHAR, @Ai_RowFrom_NUMB),
          @Ls_Where_TEXT       VARCHAR(MAX) = '',
          @Ls_InnerSelect_TEXT VARCHAR(MAX) = ' INSERT INTO #SearchResult_P1(Case_IDNO,MemberMci_IDNO, Rownum_NUMB,RowCount_NUMB)                                                                                                                                                
    				   SELECT DISTINCT OS.Case_IDNO,OS.MemberMci_IDNO,OS.Rownum_NUMB, OS.RowCount_NUMB                                                                                                                                                          
    				     FROM (                                                                                                                                                                                                   
    				       SELECT MI.Case_IDNO,MI.MemberMci_IDNO,MI.Rownum_NUMB, MI.RowCount_NUMB                                                                                                                                                      
    				       FROM (SELECT   V.Case_IDNO,V.MemberMci_IDNO  ,ROW_NUMBER() OVER(                                                                                                                                                          
    				                       ORDER BY V.Case_IDNO) AS Rownum_NUMB,                                                                                                                                                  
    				                       COUNT(1) OVER() AS RowCount_NUMB FROM(
    				             SELECT  C1.Case_IDNO, C1.MemberMci_IDNO  
    				              FROM 
    				                CMEM_Y1 C1  
    				              WHERE  Case_IDNO IN (                                                                                                                                                      
    				             SELECT  DISTINCT  C.Case_IDNO                                                                                                                                                                    
    				              FROM                                                                                                                                                                                            
								   CASE_Y1 C                                                                                                                                                
									INNER JOIN                                                                                                                                                                                                   
									  CMEM_Y1 CM ON C.Case_IDNO =  CM.Case_IDNO    
								                 AND CM.CaseRelationship_CODE IN ( ''A'' ,''P'',''C'',''D'')                                                                                                                                                                   
									INNER JOIN                                                                                                                                                                                                   
									   DEMO_Y1 D ON CM.MemberMci_IDNO = D.MemberMci_IDNO                                                                                                                                                         
							      WHERE  ';

  IF (@An_Case_IDNO IS NOT NULL)
   BEGIN
    SET @Ls_Where_TEXT = 'AND  C.Case_IDNO = ''' + CAST(@An_Case_IDNO AS VARCHAR) + '''' + CHAR(13) + CHAR(10);
   END

  IF (@An_County_IDNO IS NOT NULL)
   BEGIN
    SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND C.County_IDNO = ''' + CAST(@An_County_IDNO AS VARCHAR) + '''';
   END

  IF (@An_MemberMci_IDNO IS NOT NULL)
   BEGIN
    SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND D.MemberMci_IDNO = ''' + CAST(@An_MemberMci_IDNO AS VARCHAR) + '''';
   END

  IF (@Ad_Birth_DATE IS NOT NULL)
   BEGIN
    SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND D.Birth_DATE = ''' + CONVERT(VARCHAR, @Ad_Birth_DATE, 101) + '''';
   END

  IF (@An_MemberSsn_NUMB IS NOT NULL)
   BEGIN
    SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND D.MemberMci_IDNO IN (SELECT  MS.MemberMci_IDNO                                                                                                                   
                                                                     FROM MSSN_Y1 MS WHERE MS.MemberSsn_NUMB  = ''' + CAST(@An_MemberSsn_NUMB AS VARCHAR) + '''' + ' AND MS.EndValidity_DATE =''12/31/9999'') ';
   END

  IF (@An_CaseWelfare_IDNO IS NOT NULL)
   BEGIN
    SET @Ls_Where_TEXT = @Ls_Where_TEXT + 'AND  C.Case_IDNO  IN (Select MH.Case_IDNO                                                                                                         
                                                                         FROM MHIS_Y1 MH                                                                                                                           
                                                                          WHERE  MH.CaseWelfare_IDNO = ''' + CAST(@An_CaseWelfare_IDNO AS VARCHAR) + '''' + ' AND MH.End_DATE = ''12/31/9999'')';
   END

  IF (@Ac_File_ID IS NOT NULL)
   BEGIN
    SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND C.File_ID = ''' + @Ac_File_ID + '''';
   END

  IF (@Ac_First_NAME IS NOT NULL)
   BEGIN
    SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND D.First_NAME LIKE   ''%' + LTRIM(RTRIM(REPLACE(@Ac_First_NAME,'''',''''''))) + '%''';
   END

  IF (@Ac_Last_NAME IS NOT NULL)
   BEGIN
    IF (@Ac_SearchOptionLastName_CODE = @Lc_LastNameOptionExact_CODE)
     BEGIN
      SET @Ls_Where_TEXT = @Ls_Where_TEXT + 'AND D.Last_NAME = ''' + LTRIM(RTRIM (REPLACE(@Ac_Last_NAME,'''',''''''))) + '''';
     END
    ELSE IF (@Ac_SearchOptionLastName_CODE = @Lc_LastNameOptionStart_CODE)
     BEGIN
      SET @Ls_Where_TEXT = @Ls_Where_TEXT + 'AND D.Last_NAME LIKE ''' + LTRIM(RTRIM (REPLACE(@Ac_Last_NAME,'''',''''''))) + '%''';
     END
    ELSE IF (@Ac_SearchOptionLastName_CODE = @Lc_LastNameOptionLike_CODE)
     BEGIN
      SET @Ls_Where_TEXT = @Ls_Where_TEXT + 'AND D.Last_NAME LIKE ''%' + LTRIM(RTRIM(REPLACE(@Ac_Last_NAME,'''',''''''))) + '''';
     END
    ELSE IF (@Ac_SearchOptionLastName_CODE = @Lc_LastNameOptionSounds_CODE)
     BEGIN
      SET @Ls_Where_TEXT = @Ls_Where_TEXT + 'AND  SOUNDEX(D.Last_NAME) = SOUNDEX (''' + LTRIM(RTRIM(REPLACE(@Ac_Last_NAME,'''',''''''))) + ''')';
     END
    ELSE IF (@Ac_SearchOptionLastName_CODE = @Lc_LastNameOptionContains_CODE)
     BEGIN
      SET @Ls_Where_TEXT = @Ls_Where_TEXT + 'AND D.Last_NAME LIKE ''%' + LTRIM(RTRIM(REPLACE(@Ac_Last_NAME,'''',''''''))) + '%''';
     END
   END

  IF (@Ac_SearchOption_CODE = @Lc_SearchOptionCp_CODE)
   BEGIN
    SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND CM.CaseRelationship_CODE = ''C'' AND  CM.CaseMemberStatus_CODE = ''A'' ';
   END
  ELSE IF (@Ac_SearchOption_CODE = @Lc_SearchOptionNcp_CODE)
   BEGIN
    SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND CM.CaseRelationship_CODE IN ( ''A'' ,''P'') AND  CM.CaseMemberStatus_CODE = ''A'' ';
   END
  ELSE IF (@Ac_SearchOption_CODE = @Lc_SearchOptionDp_CODE)
   BEGIN
    SET @Ls_Where_TEXT = @Ls_Where_TEXT + ' AND CM.CaseRelationship_CODE = ''D'' ';
   END

  IF @Ls_Where_TEXT = ''
   BEGIN
    SET @Ls_InnerSelect_TEXT = SUBSTRING(LTRIM(@Ls_InnerSelect_TEXT), 1, LEN(@Ls_InnerSelect_TEXT) - 6);
   END
  ELSE
   BEGIN
    SET @Ls_Where_TEXT = SUBSTRING(LTRIM(@Ls_Where_TEXT), 4, LEN(@Ls_Where_TEXT));
   END

  SET @Ls_FullSelect_TEXT = @Ls_InnerSelect_TEXT + @Ls_Where_TEXT + @Ls_MiddleWhere_TEXT + @Ls_OuterWhere_TEXT;

  EXEC ( @Ls_FullSelect_TEXT);
 
 SELECT NCP.MemberMci_IDNO AS NcpMci_IDNO,
         NCPD.First_NAME AS NcpFirst_NAME,
         NCPD.Middle_NAME AS NcpMi_NAME,
         NCPD.Last_NAME AS NcpLast_NAME,
         NCPD.MemberSsn_NUMB AS NcpMemberSsn_NUMB,
         NCPD.Birth_DATE AS NcpBirth_DATE,
         CP.MemberMci_IDNO AS CpMci_IDNO,
         CPD.First_NAME AS CpFirst_NAME,
         CPD.Middle_NAME AS CpMi_NAME,
         CPD.Last_NAME AS CpLast_NAME,
         CPD.MemberSsn_NUMB AS CpMemberSsn_NUMB,
         CPD.Birth_DATE AS CpBirth_DATE,
         C.County_IDNO,
         CO.County_NAME,
         C.TypeCase_CODE,
         C.StatusCase_CODE,
         C.Case_IDNO,
         C.CaseCategory_CODE,
         C.File_ID,
         C.RespondInit_CODE,
         (SELECT TOP 1 MH.CaseWelfare_IDNO
            FROM MHIS_Y1 MH
           WHERE MH.Case_IDNO = C.Case_IDNO
             AND MH.End_DATE = @Ld_High_DATE
             AND   MH.CaseWelfare_IDNO = ISNULL(@An_CaseWelfare_IDNO, MH.CaseWelfare_IDNO)) AS CaseWelfare_IDNO,
             --MH.CaseWelfare_IDNO <> @Li_Zero_NUMB) 
        SR.RowCount_NUMB,
        Rownum_NUMB
    FROM  #SearchResult_P1 SR
         JOIN CASE_Y1 C
          ON SR.Case_IDNO = C.Case_IDNO
         JOIN CMEM_Y1 CP
          ON C.Case_IDNO = CP.Case_IDNO
         JOIN CMEM_Y1 NCP
          ON C.Case_IDNO = NCP.Case_IDNO
         JOIN DEMO_Y1 CPD
          ON CP.MemberMci_IDNO = CPD.MemberMci_IDNO
         JOIN DEMO_Y1 NCPD
          ON NCP.MemberMci_IDNO = NCPD.MemberMci_IDNO
          AND SR.MemberMci_IDNO = NCPD.MemberMci_IDNO
         LEFT OUTER JOIN COPT_Y1 CO
          ON C.County_IDNO = CO.County_IDNO
   WHERE CP.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND CP.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
     AND NCP.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND NCP.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE) 
  ORDER BY Rownum_NUMB;
 END; 


GO
