/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S151]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S151] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ac_Exists_INDC    CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S151
  *     DESCRIPTION       : Returns yes if the given NCP/Putative Father's member mci is avaliable.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 23-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_RespondInitInitiate_CODE       CHAR(1) = 'I',
          @Lc_RespondInitC_CODE              CHAR(1) = 'C',
          @Lc_RespondInitT_CODE              CHAR(1) = 'T',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A',
          @Lc_Yes_INDC                       CHAR(1) = 'Y',
          @Lc_No_INDC                        CHAR(2) = 'N';

  SET @Ac_Exists_INDC = @Lc_No_INDC;

  SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_INDC
    FROM CMEM_Y1 C
         JOIN CASE_Y1 E
          ON E.Case_IDNO = c.Case_IDNO
   WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO
     AND C.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
     AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND E.RespondInit_CODE IN (@Lc_RespondInitInitiate_CODE, @Lc_RespondInitC_CODE, @Lc_RespondInitT_CODE);
 END -- End of CMEM_RETRIEVE_S151

GO
