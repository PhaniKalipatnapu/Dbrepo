/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S61]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S61] (
 @An_Case_IDNO       NUMERIC(6),
 @An_MemberMci_IDNO  NUMERIC(10),
 @Ac_Exists_INDC     CHAR(1)   OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S61
  *     DESCRIPTION       : Retrieve the record count for a Case ID and MemberMci ID
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_Yes_TEXT                       CHAR(1) = 'Y',
          @Lc_No_TEXT                        CHAR(1) = 'N';
          
  SET @Ac_Exists_INDC = @Lc_No_TEXT;

  SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM CMEM_Y1 C
   WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO
     AND C.Case_IDNO = @An_Case_IDNO
     AND C.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE);
     
 END; --END OF CMEM_RETRIEVE_S61


GO
