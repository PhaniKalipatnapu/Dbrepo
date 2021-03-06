/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S48]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S48] (
 @An_Case_IDNO      NUMERIC(6, 0),
 @An_MemberMci_IDNO NUMERIC(10, 0) OUTPUT,
 @An_MemberSsn_NUMB NUMERIC(9, 0)  OUTPUT,
 @Ac_Last_NAME		CHAR(20)	   OUTPUT,
 @Ac_First_NAME		CHAR(16) 	   OUTPUT,
 @Ac_Middle_NAME	CHAR(20) 	   OUTPUT,
 @Ac_Suffix_NAME  	CHAR(4)  	   OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S48
  *     DESCRIPTION       : Retrieves the Member details for the respective Case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @An_MemberMci_IDNO = NULL,
         @An_MemberSsn_NUMB = NULL;

  DECLARE @Lc_CaseRelationshipCp_CODE     CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A';

  SELECT @An_MemberMci_IDNO = C.MemberMci_IDNO,
         @An_MemberSsn_NUMB = D.MemberSsn_NUMB,
         @Ac_Last_NAME = D.Last_NAME,  
         @Ac_First_NAME	= D.First_NAME, 
         @Ac_Middle_NAME = D.Middle_NAME,
         @Ac_Suffix_NAME = D.Suffix_NAME          
    FROM CMEM_Y1 C
         JOIN DEMO_Y1 D
          ON C.MemberMci_IDNO = D.MemberMci_IDNO
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND C.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
     AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
 END; --End Of Procedure CMEM_RETRIEVE_S48


GO
