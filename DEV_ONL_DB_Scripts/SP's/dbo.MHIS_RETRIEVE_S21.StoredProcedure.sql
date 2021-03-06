/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S21]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S21] (@An_Case_IDNO                      NUMERIC (6, 0),
                                    @An_WelfareMemberMci_IDNO          NUMERIC (10, 0) OUTPUT,
                                    @An_CaseWelfare_IDNO               NUMERIC (10, 0) OUTPUT)
AS
   /*
   *     PROCEDURE NAME     : MHIS_RETRIEVE_S21
    *     DESCRIPTION       : Retrieve Case Welfare Idno and Member Welfare Idno for a Member Idno, Case Idno, and Welfare Type.
    *     DEVELOPED BY      : IMP Team
    *     DEVELOPED ON      : 12/14/2011
    *     MODIFIED BY       :
    *     MODIFIED ON       :
    *     VERSION NO        : 1
   */
   BEGIN
      DECLARE
         @Lc_CaseRelationshipCp_CODE CHAR (1) = 'C',
         @Lc_CaseMemberStatusActive_CODE CHAR (1) = 'A',
         @Lc_WelfareTypeTanf_CODE CHAR (1) = 'A';

      SELECT TOP 1
             @An_CaseWelfare_IDNO = MH.CaseWelfare_IDNO,
             @An_WelfareMemberMci_IDNO = MH.WelfareMemberMci_IDNO
        FROM MHIS_Y1 MH
       WHERE MH.MemberMci_IDNO =
                (SELECT CM.MemberMci_IDNO
                   FROM CMEM_Y1 CM
                  WHERE     CM.Case_IDNO = @An_Case_IDNO
                        AND CM.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                        AND CM.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)
             AND MH.Case_IDNO = @An_Case_IDNO
             AND MH.TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE;
   END

GO
