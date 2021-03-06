/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S65]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S65] (  
 @An_Case_IDNO         NUMERIC(6, 0)  ,
 @Ac_TypeWelfare_CODE  CHAR(1)
 )  
AS  
 /*  
  *     PROCEDURE NAME    : MHIS_RETRIEVE_S65  
  *     DESCRIPTION       : Retrieves the Case Welfare ID for the respective case and TypeWelfare_CODE from MemberWelfareDetails.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 12-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */  
 BEGIN  
  
  DECLARE  
  @Lc_TypeWelfareFosterCare_CODE        CHAR(1) = 'J',  
  @Lc_TypeWelfareIve_CODE               CHAR(1) = 'F',
  @Lc_CaseRelationshipDependent_CODE    CHAR(1) = 'D',
  @Lc_CaseMemberStatusActive_CODE       CHAR(1) = 'A',
  @Li_Zero_NUMB                          INT     = 0,
  @Ld_System_DATE                       DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  
  SELECT DISTINCT M.CaseWelfare_IDNO  
    FROM MHIS_Y1 M JOIN CMEM_Y1 C
  ON   M.MemberMci_IDNO=C.MemberMci_IDNO
    AND CaseRelationship_CODE = @Lc_CaseRelationshipDependent_CODE
    AND CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
   WHERE M.Case_IDNO = @An_Case_IDNO  
     AND( M.TypeWelfare_CODE  = @Ac_TypeWelfare_CODE
     OR(  @Lc_TypeWelfareFosterCare_CODE = @Ac_TypeWelfare_CODE
          AND M.TypeWelfare_CODE IN (@Lc_TypeWelfareFosterCare_CODE,@Lc_TypeWelfareIve_CODE)))
          AND @Ld_System_DATE BETWEEN Start_DATE AND End_DATE
     AND M.CaseWelfare_IDNO >@Li_Zero_NUMB ;  
 END; --End Of MHIS_RETRIEVE_S65   
GO
