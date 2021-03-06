/****** Object:  StoredProcedure [dbo].[FCMTH_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FCMTH_RETRIEVE_S1](
 @An_Case_IDNO    NUMERIC(6, 0),
 @Ai_RowFrom_NUMB SMALLINT,
 @Ai_RowTo_NUMB   SMALLINT
 )
AS
 /*
  *     PROCEDURE NAME    : FCMTH_RETRIEVE_S1
  *     DESCRIPTION       : Retrieves the frozen case marital history for a given case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16th-May-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT A.MemberMci_IDNO,
         A.ChildFull_NAME,
         A.ChildBirth_DATE,
         A.Parent1Full_NAME,
         A.Parent2Full_NAME,
         A.Marriage_DATE,
         A.MarriageStateOrCountry_CODE,
         A.Divorce_DATE,
         A.DivorceStateOrCountry_CODE,
         A.SameSexRelationship_INDC,
         A.MaritalSource_TEXT,
         A.RowCount_NUMB
    FROM (SELECT f.MemberMci_IDNO,
                 f.ChildFull_NAME,
                 f.ChildBirth_DATE,
                 f.Parent1Full_NAME,
                 f.Parent2Full_NAME,
                 f.Marriage_DATE,
                 f.MarriageStateOrCountry_CODE,
                 f.Divorce_DATE,
                 f.DivorceStateOrCountry_CODE,
                 f.SameSexRelationship_INDC,
                 f.MaritalSource_TEXT,
                 COUNT(1) OVER() AS RowCount_NUMB,
                 ROW_NUMBER() OVER ( ORDER BY f.MemberMci_IDNO ) AS ROWNUM
            FROM FCMTH_Y1 f
           WHERE f.Case_IDNO = @An_Case_IDNO) AS A
   WHERE A.ROWNUM BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB;
 END;


GO
