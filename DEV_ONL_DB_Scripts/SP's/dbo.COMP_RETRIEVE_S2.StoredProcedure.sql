/****** Object:  StoredProcedure [dbo].[COMP_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[COMP_RETRIEVE_S2]  
(
     @Ac_OrderedParty_CODE		 CHAR(1),
     @Ac_ComplianceType_CODE	 CHAR(2),
     @An_Case_IDNO		         NUMERIC(6,0),
     @Ad_Effective_DATE			 DATE,
     @Ad_End_DATE				 DATE,
     @Ai_Count_QNTY              INT     OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : COMP_RETRIEVE_S2
 *     DESCRIPTION       : Checks if the given compliance schedule type and ordered party exist 
						   for a case associated with the compliance schedule.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 17-JAN-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN

      SET @Ai_Count_QNTY = NULL;

	  DECLARE @Lc_ComplianceStatusAc_CODE	 CHAR(2) = 'AC',
			  @Lc_ComplianceStatusNC_CODE	 CHAR(2) = 'NC',
			  @Ld_High_DATE                  DATE    = '12/31/9999';
        
      SELECT @Ai_Count_QNTY = COUNT(1)
        FROM COMP_Y1 a
       WHERE a.Case_IDNO             = @An_Case_IDNO 
         AND a.ComplianceType_CODE   = @Ac_ComplianceType_CODE 
         AND a.OrderedParty_CODE     = @Ac_OrderedParty_CODE 
         AND a.ComplianceStatus_CODE IN (@Lc_ComplianceStatusAc_CODE, @Lc_ComplianceStatusNC_CODE)
         AND (@Ad_Effective_DATE BETWEEN a.Effective_DATE AND a.End_DATE
              OR @Ad_End_DATE BETWEEN a.Effective_DATE AND a.End_DATE
              OR a.Effective_DATE BETWEEN @Ad_Effective_DATE AND @Ad_End_DATE
			  OR a.End_DATE BETWEEN @Ad_Effective_DATE AND @Ad_End_DATE)
         AND a.EndValidity_DATE      = @Ld_High_DATE;
                  
END --END OF COMP_RETRIEVE_S2


GO
