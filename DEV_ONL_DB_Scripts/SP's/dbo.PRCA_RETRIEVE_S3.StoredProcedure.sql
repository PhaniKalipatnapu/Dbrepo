/****** Object:  StoredProcedure [dbo].[PRCA_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PRCA_RETRIEVE_S3] (
 @An_WelfareCaseCounty_IDNO  NUMERIC(3,0),
 @Ad_From_DATE		         DATE,
 @Ad_To_DATE		         DATE, 
 @An_WelfareCaseCount_NUMB   NUMERIC(6,0) OUTPUT
 )
AS    
    
/*    
 *     PROCEDURE NAME    : PRCA_RETRIEVE_S3    
 *     DESCRIPTION       : Retrieve the Total casecount of welfare. 
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 27-NOV-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
 */    
BEGIN    
       DECLARE @Lc_ReferralProcessD_CODE CHAR(1) = 'D';

	   SET @An_WelfareCaseCount_NUMB = NULL;	       
	   
	   SELECT @An_WelfareCaseCount_NUMB  = COUNT (DISTINCT b.CaseWelfare_IDNO)
	    FROM PRCA_Y1 b 
	   WHERE b.WelfareCaseCounty_IDNO = @An_WelfareCaseCounty_IDNO
         AND b.ReferralReceived_DATE >= ISNULL(@Ad_From_DATE,b.ReferralReceived_DATE)
         AND b.ReferralReceived_DATE <= ISNULL(@Ad_To_DATE,b.ReferralReceived_DATE)
		 AND b.ReferralProcess_CODE != @Lc_ReferralProcessD_CODE;
		 
END;--End of PRCA_RETRIEVE_S3.    


GO
