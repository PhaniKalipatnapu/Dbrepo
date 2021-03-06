/****** Object:  StoredProcedure [dbo].[APMH_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APMH_RETRIEVE_S1](
 @An_Application_IDNO      NUMERIC(15, 0),
 @Ac_CaseRelationship_CODE CHAR(1),
 @Ai_Count_QNTY            INT OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : APMH_RETRIEVE_S1  
  *     DESCRIPTION       : Gets the record count for the given Application Id, Member Id where any one of the Type of Welfare is 'Medicaid' and other Pa type are 'Non tanf' for respective application.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 29-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SET @Ai_Count_QNTY = 0;

  DECLARE @Lc_TypeWelfareMedicaid_CODE CHAR(1) = 'M',
          @Lc_TypeWelfareNonTanf_CODE  CHAR(1) = 'N',
          @Ld_High_DATE                DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM APMH_Y1 A,
         APCM_Y1 A1
   WHERE A.Application_IDNO = A1.Application_IDNO
     AND A.MemberMci_IDNO = A1.MemberMci_IDNO
     AND A.Application_IDNO = @An_Application_IDNO
     AND A.TypeWelfare_CODE IN (@Lc_TypeWelfareMedicaid_CODE)
     AND (@Ac_CaseRelationship_CODE IS NOT NULL
          AND A1.CaseRelationship_CODE IN (@Ac_CaseRelationship_CODE)
           OR @Ac_CaseRelationship_CODE IS NULL)
     AND NOT EXISTS (SELECT A.TypeWelfare_CODE
                       FROM APMH_Y1 A
                      WHERE A.Application_IDNO = @An_Application_IDNO
                        AND A.TypeWelfare_CODE NOT IN (@Lc_TypeWelfareMedicaid_CODE, @Lc_TypeWelfareNonTanf_CODE) AND A.EndValidity_DATE = @Ld_High_DATE )
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; -- End Of APMH_RETRIEVE_S1  

 
GO
