/****** Object:  StoredProcedure [dbo].[APCM_RETRIEVE_S35]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCM_RETRIEVE_S35] (
 @An_Application_IDNO      NUMERIC(10),
 @Ac_CaseRelationshipCP_CODE CHAR(1),
 @Ac_MemberSex_CODE           CHAR(1) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : APCM_RETRIEVE_S35  
  *     DESCRIPTION       : To get the Member Sex Code for given Application & Case Relation Code.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 18-APR-2012  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Lc_CaseRelationshipA_CODE CHAR(1) = 'A',
          @Lc_CaseRelationshipP_CODE CHAR(1) = 'P',
          @Ld_High_DATE              DATE = '12/31/9999';
  
SELECT @Ac_MemberSex_CODE  = D.MemberSex_CODE  
	FROM APCM_Y1 C JOIN APDM_Y1 D  ON C.Application_IDNO = D.Application_IDNO AND C.MemberMci_IDNO = D.MemberMci_IDNO
WHERE C.Application_IDNO = @An_Application_IDNO 
     AND ( C.CaseRelationship_CODE = ISNULL(@Ac_CaseRelationshipCP_CODE,@Lc_CaseRelationshipA_CODE) OR 
           C.CaseRelationship_CODE = ISNULL(@Ac_CaseRelationshipCP_CODE,@Lc_CaseRelationshipP_CODE))
     AND C.EndValidity_DATE = @Ld_High_DATE AND D.EndValidity_DATE = @Ld_High_DATE;

 END; -- End Of APCM_RETRIEVE_S35						


GO
