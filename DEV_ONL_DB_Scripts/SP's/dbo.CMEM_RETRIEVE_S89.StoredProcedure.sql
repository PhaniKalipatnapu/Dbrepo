/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S89]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S89] 
(	@An_MemberMci_IDNO                 NUMERIC (10, 0),
    @An_Case_IDNO                      NUMERIC (6, 0) = NULL,
    @Ac_CaseRelationship_CODE          CHAR (1) OUTPUT,
    @Ac_CaseMemberStatus_CODE          CHAR (1) OUTPUT,
	@An_TransactionEventSeq_NUMB	   NUMERIC(19, 0) OUTPUT)
AS
   /*
    *     PROCEDURE NAME    : CMEM_RETRIEVE_S89
    *     DESCRIPTION       : To Retrieve Relationship and Member Status for a give Member.
    *     DEVELOPED BY      : IMP Team
    *     DEVELOPED ON      : 12/12/2011
    *     MODIFIED BY       :
    *     MODIFIED ON       :
    *     VERSION NO        : 1
   */

   BEGIN
   
      SET @Ac_CaseRelationship_CODE = NULL;
      SET @Ac_CaseMemberStatus_CODE = NULL;
	  SET @An_TransactionEventSeq_NUMB = NULL;
      
      SELECT TOP 1 @Ac_CaseRelationship_CODE = cm.CaseRelationship_CODE,
             @Ac_CaseMemberStatus_CODE = cm.CaseMemberStatus_CODE,
			 @An_TransactionEventSeq_NUMB = cm.TransactionEventSeq_NUMB
        FROM CMEM_Y1 cm
      WHERE cm.MemberMci_IDNO = @An_MemberMci_IDNO 
      AND cm.Case_IDNO = ISNULL (@An_Case_IDNO, cm.Case_IDNO);
   END

GO
