/****** Object:  StoredProcedure [dbo].[PRCA_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PRCA_RETRIEVE_S4](
 @An_Application_IDNO       NUMERIC(15, 0),
 @An_CaseWelfare_IDNO		NUMERIC(10,0) OUTPUT,    
 @An_AgSequence_NUMB		NUMERIC(4,0) OUTPUT, 
 @Ad_ReferralReceived_DATE  DATE OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : PRCA_RETRIEVE_S4  
  *     DESCRIPTION       : Retrieve Pending Referrals Details for given Application idno 
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 22-MAR-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT @An_CaseWelfare_IDNO = NULL,
         @An_AgSequence_NUMB = NULL,        
         @Ad_ReferralReceived_DATE = NULL;
         
  DECLARE @Lc_ReferralProcessP_CODE CHAR(1) = 'P';

  SELECT @An_CaseWelfare_IDNO = P.CaseWelfare_IDNO,         
         @An_AgSequence_NUMB = P.AgSequence_NUMB,         
         @Ad_ReferralReceived_DATE = P.ReferralReceived_DATE
    FROM PRCA_Y1 P
   WHERE P.Application_IDNO = @An_Application_IDNO 
   AND P.ReferralProcess_CODE = @Lc_ReferralProcessP_CODE
 END; -- End Of PRCA_RETRIEVE_S4

GO
