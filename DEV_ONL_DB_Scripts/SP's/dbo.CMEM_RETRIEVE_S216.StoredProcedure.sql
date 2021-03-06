/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S216]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S216] (
 @Ac_BirthCertificate_ID             CHAR(20)
 )
AS

/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S216
 *     DESCRIPTION       : Retrieve the MemberMci Idno associated with the BirthCertificate ID
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 25-Jun-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN 
DECLARE @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A';

SELECT C.Case_IDNO        
    FROM DEMO_Y1 D
         LEFT OUTER JOIN MPAT_Y1 M
          ON (D.MemberMci_IDNO = M.MemberMci_IDNO)
         JOIN CMEM_Y1 C
          ON (D.MemberMci_IDNO = C.MemberMci_IDNO)
   WHERE M.BirthCertificate_ID = @Ac_BirthCertificate_ID
	AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;       
 END; --END OF CMEM_RETRIEVE_S216

GO
