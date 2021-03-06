/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S126]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S126] (
 @An_OtherParty_IDNO NUMERIC(9, 0),
 @An_Fein_IDNO       NUMERIC(9, 0),
 @Ai_RowFrom_NUMB    INT = 1,
 @Ai_RowTo_NUMB      INT = 10
 )
AS
 /*    
  *     PROCEDURE NAME    : DEMO_RETRIEVE_S126    
  *     DESCRIPTION       : Retrieve Member details for an Other Party Federal number and Other Party number.   
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 05-AUG-2011  
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  DECLARE @Lc_CaseRelationshipCp_CODE        CHAR(1) = 'C',
          @Lc_CaseRelationshipNCp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Li_Zero_NUMB                      SMALLINT = 0,
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
          @Ld_High_DATE                      DATE = '12/31/9999',
          @Lc_OthpTypeExact_CODE             CHAR(1) = 'E';
  DECLARE @Ls_SqlParameters_TEXT NVARCHAR(max),
          @Ls_SqlStatement_TEXT  NVARCHAR(max);

  SET @Ls_SqlStatement_TEXT =N'
  SELECT Y.MemberMci_IDNO,
         Y.Last_NAME,
         Y.Suffix_NAME,
         Y.First_NAME,
         Y.Middle_NAME,
         Y.MemberSsn_NUMB,
         Y.FILE_ID,
         Y.County_IDNO,
         Y.County_NAME,
         Y.Case_IDNO,
         RowCount_NUMB
    FROM (SELECT X.MemberMci_IDNO,
                 X.Last_NAME,
                 X.Suffix_NAME,
                 X.First_NAME,
                 X.Middle_NAME,
                 X.MemberSsn_NUMB,
                 X.FILE_ID,
                 (SELECT G.County_IDNO
                    FROM CASE_Y1 G
                   WHERE G.Case_IDNO = X.Case_IDNO) AS County_IDNO,
                 X.County_NAME,
                 X.Case_IDNO,
                 X.RowCount_NUMB,
                 X.ORD_ROWNUM AS Row_Num
            FROM (SELECT C.MemberMci_IDNO,
                         C.Last_NAME,
                         C.Suffix_NAME,
                         C.First_NAME,
                         C.Middle_NAME,
                         C.MemberSsn_NUMB,
                         E.FILE_ID,
                         (SELECT f.County_NAME
                            FROM COPT_Y1 f
                           WHERE f.County_IDNO = a.County_IDNO
                             AND a.County_IDNO != @Li_Zero_NUMB) AS County_NAME,
                         D.Case_IDNO AS Case_IDNO,
                         COUNT (1) OVER () AS RowCount_NUMB,
                         ROW_NUMBER () OVER (ORDER BY c.MemberMci_IDNO, c.MemberSsn_NUMB ) AS ORD_ROWNUM
                    FROM OTHP_Y1 A
                         JOIN EHIS_Y1 B
                          ON a.OtherParty_IDNO = b.OthpPartyEmpl_IDNO
                         JOIN DEMO_Y1 C
                          ON b.MemberMci_IDNO = c.MemberMci_IDNO
                         JOIN CMEM_Y1 D
                          ON c.MemberMci_IDNO = d.MemberMci_IDNO
                         JOIN CASE_Y1 E
                          ON d.Case_IDNO = e.Case_IDNO
                   WHERE B.EndEmployment_DATE = @Ld_High_DATE
                     ' + CASE
                                                       WHEN @An_OtherParty_IDNO IS NOT NULL
                                                        THEN '  
                     AND a.OtherParty_IDNO = @An_OtherParty_IDNO '
                                                       ELSE ' '
                                                      END + CASE
                                                             WHEN @An_Fein_IDNO IS NOT NULL
                                                              THEN '    
                     AND a.Fein_IDNO = @An_Fein_IDNO '
                                                             ELSE ' '
                                                            END + '
                     AND D.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                     AND D.CaseRelationship_CODE IN (@Lc_CaseRelationshipNCp_CODE, @Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                     AND A.TypeOthp_CODE = @Lc_OthpTypeExact_CODE
                     AND A.EndValidity_DATE = @Ld_High_DATE) AS X 
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.Row_Num >= @Ai_RowFrom_NUMB
   ORDER BY Y.Row_Num
   ';
  SET @Ls_SqlParameters_TEXT='
		  @An_OtherParty_IDNO NUMERIC(9, 0),
		  @An_Fein_IDNO       NUMERIC(9, 0),
		  @Ai_RowFrom_NUMB    INT,
		  @Ai_RowTo_NUMB      INT,
		  @Lc_CaseRelationshipCp_CODE        CHAR(1),
          @Lc_CaseRelationshipNCp_CODE       CHAR(1),
          @Lc_CaseRelationshipPutFather_CODE CHAR(1),
          @Li_Zero_NUMB                      SMALLINT,
          @Lc_StatusCaseMemberActive_CODE    CHAR(1),
          @Ld_High_DATE                      DATE ,
          @Lc_OthpTypeExact_CODE             CHAR(1)
          ';

  EXEC SP_EXECUTESQL
   @Ls_SqlStatement_TEXT,
   @Ls_SqlParameters_TEXT,
   @An_OtherParty_IDNO,
   @An_Fein_IDNO,
   @Ai_RowFrom_NUMB,
   @Ai_RowTo_NUMB,
   @Lc_CaseRelationshipCp_CODE,
   @Lc_CaseRelationshipNCp_CODE,
   @Lc_CaseRelationshipPutFather_CODE,
   @Li_Zero_NUMB,
   @Lc_StatusCaseMemberActive_CODE,
   @Ld_High_DATE,
   @Lc_OthpTypeExact_CODE;
 END; -- END OF DEMO_RETRIEVE_S126  
GO
