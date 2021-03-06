/****** Object:  StoredProcedure [dbo].[FSRT_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[FSRT_RETRIEVE_S8]
(
	@Ad_Disposition_DATE		DATE,
	@An_Case_IDNO				NUMERIC(6,0),
	@Ad_Service_DATE			DATE OUTPUT
)
AS
 
/*                                                                                     
  *     PROCEDURE NAME    : FSRT_RETRIEVE_S8                                           
  *     DESCRIPTION       : This procedure is used to retrieve the service date.
  *     DEVELOPED BY      : IMP TEAM                                                
  *     DEVELOPED ON      : 03/09/2012  
  *     MODIFIED BY       :                                                             
  *     MODIFIED ON       :                                                             
  *     VERSION NO        : 1                                                           
  */
BEGIN

	    SET @Ad_Service_DATE = NULL;
 
	DECLARE @Ld_Low_DATE				DATE    = '01/01/0001',
			@Ld_High_DATE               DATE    = '12/31/9999',
			@Lc_ServiceResultP_CODE		CHAR(1) = 'P',
			@Lc_ServiceResultN_CODE     CHAR(1) = 'N',
			@Lc_ReasonStatusDB_CODE     CHAR(2) = 'DB',
			@Lc_ActivityMajorCASE_CODE  CHAR(4) = 'CASE',
			@Lc_ActivityMajorESTP_CODE	CHAR(4) = 'ESTP',
			@Lc_StatusCOMP_CODE			CHAR(4) = 'COMP',
			@Lc_ActivityMinorANDDI_CODE CHAR(5) = 'ANDDI',
			@Lc_ActivityMinorROPDP_CODE CHAR(5) = 'ROPDP';
	  
	  	  SELECT @Ad_Service_DATE = ISNULL((SELECT TOP 1 f.Service_DATE
			  FROM SORD_Y1 b JOIN FSRT_Y1 f
			    ON b.Case_IDNO = f.Case_IDNO
			 WHERE b.Case_IDNO = @An_Case_IDNO
			   AND f.ServiceResult_CODE = @Lc_ServiceResultP_CODE
			   AND f.EndValidity_DATE = @Ld_High_DATE			   
			   AND (SELECT MAX(d.Service_DATE) 
					  FROM FSRT_Y1 d 
					 WHERE d.Case_IDNO = @An_Case_IDNO
					   AND d.EndValidity_DATE = @Ld_High_DATE)	<= @Ad_Disposition_DATE),											
				 (SELECT TOP 1 f.Service_DATE 
						  FROM DMNR_Y1 b JOIN FSRT_Y1 f
							ON b.Case_IDNO = f.Case_IDNO
						   AND b.Case_IDNO = @An_Case_IDNO
						   AND b.Status_CODE = @Lc_StatusCOMP_CODE
						   AND f.EndValidity_DATE = @Ld_High_DATE
						   AND ((b.ActivityMajor_CODE = @Lc_ActivityMajorESTP_CODE
									AND b.ActivityMinor_CODE = @Lc_ActivityMinorANDDI_CODE 
									AND b.ReasonStatus_CODE = @Lc_ReasonStatusDB_CODE
									AND f.ServiceResult_CODE = @Lc_ServiceResultN_CODE)
								OR (b.ActivityMajor_CODE = @Lc_ActivityMajorCASE_CODE  
									AND b.ActivityMinor_CODE = @Lc_ActivityMinorROPDP_CODE 
									AND f.ServiceResult_CODE = @Lc_ServiceResultP_CODE))							
						   AND (SELECT MAX(d.Service_DATE) 
								  FROM FSRT_Y1 d 
								 WHERE d.Case_IDNO = @An_Case_IDNO
								   AND d.EndValidity_DATE = @Ld_High_DATE)	<= @Ad_Disposition_DATE));
	 
END --End Of Procedure FSRT_RETRIEVE_S8
 

GO
