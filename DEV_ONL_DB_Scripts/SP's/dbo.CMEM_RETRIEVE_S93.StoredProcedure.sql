/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S93]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S93] (
 @An_Case_IDNO      NUMERIC(6, 0),
 @An_MemberMci_IDNO NUMERIC(10, 0) OUTPUT,
 @Ac_Last_NAME      CHAR(20) OUTPUT,
 @Ac_First_NAME     CHAR(16) OUTPUT,
 @Ac_Middle_NAME    CHAR(20) OUTPUT,
 @Ac_Suffix_NAME    CHAR(4) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S93  
  *     DESCRIPTION       : Retrieves the Member details for the respective Case. 
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 21-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT @An_MemberMci_IDNO = NULL,
         @Ac_Last_NAME = NULL,
         @Ac_First_NAME = NULL,
         @Ac_Middle_NAME = NULL,
         @Ac_Suffix_NAME = NULL;

  DECLARE @Lc_CaseRelationshipCp_CODE     CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A',
          @Li_Zero_NUMB                   SMALLINT = 0,
          @Li_One_NUMB                    SMALLINT = 1;

  SELECT @An_MemberMci_IDNO = Y.MemberMci_IDNO,
         @Ac_Last_NAME = Y.Last_NAME,
         @Ac_First_NAME = Y.First_NAME,
         @Ac_Middle_NAME = Y.Middle_NAME,
         @Ac_Suffix_NAME = Y.Suffix_NAME
    FROM (SELECT X.MemberMci_IDNO,
                 X.Last_NAME,
                 X.First_NAME,
                 X.Middle_NAME,
                 X.Suffix_NAME,
                 X.CaseMemberStatus_CODE,
                 ROW_NUMBER() OVER ( ORDER BY Xcolumn ) AS Row_NUMB
            FROM (SELECT C.MemberMci_IDNO,
                         D.Last_NAME,
                         D.First_NAME,
                         D.Middle_NAME,
                         D.Suffix_NAME,
                         C.CaseMemberStatus_CODE,
                         @Li_Zero_NUMB AS Xcolumn
                    FROM CMEM_Y1 C
                         JOIN DEMO_Y1 D
                          ON C.MemberMci_IDNO = D.MemberMci_IDNO
                   WHERE C.Case_IDNO = @An_Case_IDNO
                     AND C.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                  ) AS X
          ) AS Y
   WHERE (Y.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
           OR Y.Row_NUMB = @Li_One_NUMB);
 END; -- End Of CMEM_RETRIEVE_S93

GO
