/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S125]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[DMNR_RETRIEVE_S125]
 (
   @An_Case_IDNO                    NUMERIC(6, 0),  
   @Ad_Status_DATE					DATE  OUTPUT
 )
As
 
 /*                                                                                                                                                     
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S125                                                                                                            
  *     DESCRIPTION       : Retrieve the Support order modified date for the case.  
  *     DEVELOPED BY      : IMP Team                                                                                                                  
  *     DEVELOPED ON      : 16-MAY-2012                                                                                                                 
  *     MODIFIED BY       :                                                                                                                             
  *     MODIFIED ON       :                                                                                                                             
  *     VERSION NO        : 1                                                                                                                           
 */    
 
BEGIN
   
	SET @Ad_Status_DATE =NULL;
  
  	DECLARE @Lc_TypeDebtCS_CODE			CHAR(4) = 'CS',
  			@Lc_TypeDebtMS_CODE			CHAR(5) = 'MS',
  			@Lc_High_DATE				DATE = '12/31/9999',
  			@Ld_Low_DATE				DATE = '01/01/0001';

	SELECT @Ad_Status_DATE = ISNULL(MAX(BeginValidity_DATE), @Ld_Low_DATE)
	FROM  OBLE_Y1
	WHERE Case_IDNO = @An_Case_IDNO
		AND TypeDebt_CODE IN (@Lc_TypeDebtCS_CODE, @Lc_TypeDebtMS_CODE)
		AND EndValidity_DATE = @Lc_High_DATE
                            
                            
 END; -- END OF DMNR_RETRIEVE_S125                                
GO
