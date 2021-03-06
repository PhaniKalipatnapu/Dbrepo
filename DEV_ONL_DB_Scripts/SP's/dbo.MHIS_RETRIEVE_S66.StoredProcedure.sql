/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S66]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S66] (  
 @An_Case_IDNO         NUMERIC(6, 0)  ,
 @Ad_Start_DATE        DATE,
 @Ad_End_DATE          DATE,
 @Ac_TypeWelfare_CODE  CHAR(1) OUTPUT
 )  
AS  
 /*  
  *     PROCEDURE NAME    : MHIS_RETRIEVE_S66 
  *     DESCRIPTION       : Retrieves the TypeWelfare_CODE from MemberWelfareDetails.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 01/05/2012 
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */  
 BEGIN  
  
  DECLARE  
  @Lc_CaseRelationshipCp_CODE    CHAR(1) = 'C';
  
SELECT @Ac_TypeWelfare_CODE = MH.TypeWelfare_CODE  FROM MHIS_Y1 MH inner join CMEM_Y1 CM 
ON MH.Case_IDNO = CM.Case_IDNO 
AND MH.MemberMci_IDNO = CM.MemberMci_IDNO 
WHERE 
MH.Case_IDNO = @An_Case_IDNO 
AND CM.Caserelationship_CODE  = @Lc_CaseRelationshipCp_CODE 
AND
MH.Start_DATE = @Ad_Start_DATE
AND 
MH.End_DATE = @Ad_End_DATE 

 END; --End Of MHIS_RETRIEVE_S66  
 
 
GO
