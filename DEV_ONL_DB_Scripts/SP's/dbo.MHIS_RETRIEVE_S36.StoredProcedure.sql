/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S36]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S36] (
 @An_MemberMci_IDNO NUMERIC(10, 0)
 )
AS
 /*    
  *     PROCEDURE NAME    : MHIS_RETRIEVE_S36    
  *     DESCRIPTION       : Retrieves the Case Welfare ID for the respective Member from MemberWelfareDetails.   
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 19-SEP-2011   
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  DECLARE @Lc_TypeWelfareFosterCare_CODE CHAR(1) = 'J',
          @Lc_TypeWelfareMedicaid_CODE   CHAR(1) = 'M',
          @Lc_TypeWelfareNonIve_CODE     CHAR(1) = 'F',
          @Lc_TypeWelfareTanf_CODE       CHAR(1) = 'A';

  SELECT DISTINCT M.CaseWelfare_IDNO
    FROM MHIS_Y1 M
         JOIN CMEM_Y1 C
          ON M.Case_IDNO = C.Case_IDNO
             AND M.MemberMci_IDNO = C.MemberMci_IDNO
   WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO
     AND M.TypeWelfare_CODE IN (@Lc_TypeWelfareTanf_CODE, @Lc_TypeWelfareNonIve_CODE, @Lc_TypeWelfareFosterCare_CODE, @Lc_TypeWelfareMedicaid_CODE)
     AND LTRIM(RTRIM(M.CaseWelfare_IDNO)) IS NOT NULL;
 END; --End of MHIS_RETRIEVE_S36  

GO
