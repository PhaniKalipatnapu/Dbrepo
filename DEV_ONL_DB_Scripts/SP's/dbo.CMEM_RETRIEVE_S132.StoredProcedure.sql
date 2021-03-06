/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S132]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S132] (
 @An_MemberMci_IDNO	NUMERIC(10,0),
 @Ai_RowFrom_NUMB  	INT = 1,
 @Ai_RowTo_NUMB    	INT = 10                          
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S132
  *     DESCRIPTION       : Retrieve Unique ID generated for the Case, Member Status on the Case and Members Case Relation from Case Members table for Unique ID Assigned to the Member and retrieve the Status of the Case and Case Type by deriving it from Type of the Case and Case Category from Case Details table for the Case of the Unique ID Assigned to the Member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 18-DEC-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
   BEGIN

       SELECT X.Case_IDNO , 
         	  X.CaseRelationship_CODE , 
         	  TypeCase_CODE , 
         	  CaseCategory_CODE,
         	  X.StatusCase_CODE , 
         	  X.CaseMemberStatus_CODE , 
         	  X.RowCount_NUMB  
      FROM (
            SELECT Y.Case_IDNO, 
                   Y.CaseRelationship_CODE, 
                   Y.CaseCategory_CODE,
                   Y.TypeCase_CODE, 
                   Y.StatusCase_CODE, 
                   Y.CaseMemberStatus_CODE, 
                   Y.RowCount_NUMB,  
                   Y.ORD_ROWNUM 
            FROM ( 
                 SELECT a.Case_IDNO, 
                        a.CaseRelationship_CODE, 
                        b.TypeCase_CODE, 
                        b.CaseCategory_CODE, 
                        b.StatusCase_CODE, 
                        a.CaseMemberStatus_CODE, 
                        COUNT(1) OVER() AS RowCount_NUMB, 
                        ROW_NUMBER() OVER(ORDER BY a.Case_IDNO) AS ORD_ROWNUM
                   FROM CMEM_Y1 a
                        JOIN
                        CASE_Y1 b
                     ON a.Case_IDNO = b.Case_IDNO  
                  WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                ) Y
            WHERE Y.ORD_ROWNUM <= @Ai_RowTo_NUMB
         ) X
      WHERE X.ORD_ROWNUM >= @Ai_RowFrom_NUMB
ORDER BY ORD_ROWNUM;   
                  
END; -- END OF CMEM_RETRIEVE_S132


GO
