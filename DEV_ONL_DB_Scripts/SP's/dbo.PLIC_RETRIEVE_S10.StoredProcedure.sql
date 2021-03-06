/****** Object:  StoredProcedure [dbo].[PLIC_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PLIC_RETRIEVE_S10] (
 @An_MemberMci_IDNO			NUMERIC(10, 0),
 @Ad_SuspLicense_DATE       DATE OUTPUT
 )
AS
 /*      
  *     PROCEDURE NAME    : PLIC_RETRIEVE_S10      
  *     DESCRIPTION       : Retrieve the date NCP’s information was submitted to the motor vehicle agency for driver’s license suspension.
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 15-SEP-2011      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
  */
 BEGIN
	SET @Ad_SuspLicense_DATE = NULL;

	DECLARE @Lc_LicenseStatusI_CODE CHAR(1) = 'I',
			@Lc_TypeLicenseDr_CODE	CHAR(2) = 'DR',
			@Lc_IssuingStateDe_CODE	CHAR(2) = 'DE',
			@Ld_High_DATE			DATE = '12/31/9999';

	SELECT @Ad_SuspLicense_DATE = MAX(SuspLicense_DATE )
	FROM PLIC_Y1
	WHERE MemberMci_IDNO = @An_MemberMci_IDNO
		AND TypeLicense_CODE = @Lc_TypeLicenseDr_CODE
		AND IssuingState_CODE = @Lc_IssuingStateDe_CODE
		AND LicenseStatus_CODE = @Lc_LicenseStatusI_CODE
		AND EndValidity_DATE = @Ld_High_DATE
		AND SuspLicense_DATE <> @Ld_High_DATE
		AND ExpireLicense_DATE = @Ld_High_DATE;
		
 END; --End Of PLIC_RETRIEVE_S10    

GO
