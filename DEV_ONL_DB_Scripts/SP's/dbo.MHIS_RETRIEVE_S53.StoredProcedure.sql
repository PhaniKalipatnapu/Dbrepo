/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S53]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S53] (
 @An_Case_IDNO			NUMERIC(6, 0),
 @An_CaseWelfare_IDNO	NUMERIC(10, 0) OUTPUT
 )
AS
 /*                                                                      
  *     PROCEDURE NAME    : MHIS_RETRIEVE_S53                            
  *     DESCRIPTION       : Retrieves the case welfare ID for the given Case ID.                                                
  *     DEVELOPED BY      : IMP Team                       
  *     DEVELOPED ON      : 02-MAR-2011                                  
  *     MODIFIED BY       :                                              
  *     MODIFIED ON       :                                              
  *     VERSION NO        : 1                                            
 */
 BEGIN
  SET @An_CaseWelfare_IDNO = NULL;
  
DECLARE
  @Lc_TypeWelfareFosterCare_CODE  CHAR(1) = 'J',
  @Lc_TypeWelfareIve_CODE         CHAR(1) = 'F',
  @Ld_High_DATE                   DATE='12/31/9999';

  SELECT DISTINCT TOP 1 @An_CaseWelfare_IDNO = A.CaseWelfare_IDNO
    FROM MHIS_Y1 A
   WHERE A.Case_IDNO = @An_Case_IDNO
     AND A.TypeWelfare_CODE IN (@Lc_TypeWelfareFosterCare_CODE,@Lc_TypeWelfareIve_CODE)
     AND A.End_DATE = @Ld_High_DATE;
     
 END; --End of  MHIS_RETRIEVE_S53
                                          

GO
