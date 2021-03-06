/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S120]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S120]  (
     @An_Case_IDNO		 NUMERIC(6,0)       
     )        
AS
  /*   
  *     PROCEDURE NAME    : OBLE_RETRIEVE_S120   
  *     DESCRIPTION       : Retrieves the obligation details for the given case.
  *     DEVELOPED BY      : IMP Team   
  *     DEVELOPED ON      : 02-SEP-2011   
  *     MODIFIED BY       :    
  *     MODIFIED ON       :    
  *     VERSION NO        : 1   
  */

   BEGIN
      DECLARE
         @Ld_Highdate  DATE = '31-DEC-9999',
		 @Ld_Systemdate_DATE                      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
        
        SELECT  sum(OB.Periodic_AMNT) AS Periodic_AMNT, 
        OB.TypeDebt_CODE , 
        OB.FreqPeriodic_CODE 
      FROM OBLE_Y1 OB
      WHERE 
         OB.Case_IDNO = @An_Case_IDNO AND 
         OB.EndValidity_DATE = @Ld_Highdate AND 
         @Ld_Systemdate_DATE BETWEEN OB.BeginObligation_DATE AND OB.EndObligation_DATE
      GROUP BY OB.TypeDebt_CODE, OB.FreqPeriodic_CODE;                  
END


GO
