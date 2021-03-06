/****** Object:  StoredProcedure [dbo].[PLIC_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PLIC_RETRIEVE_S11] (
 @An_MemberMci_IDNO			NUMERIC(10, 0),
 @Ad_SuspLicense_DATE       DATE OUTPUT
 )
AS
 /*      
  *     PROCEDURE NAME    : PLIC_RETRIEVE_S11      
  *     DESCRIPTION       : Retrieve the recent date NCP’s information was submitted for a professional licensing suspension.
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 15-SEP-2011      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
  */
 BEGIN
	SET @Ad_SuspLicense_DATE = NULL;

	DECLARE @Lc_LicenseStatusI_CODE CHAR(1) = 'I',
			@Ln_OthpLicAgent_IDNO	NUMERIC(9, 0) = 999999972,
			@Ld_High_DATE			DATE = '12/31/9999';

	SELECT @Ad_SuspLicense_DATE = MAX(SuspLicense_DATE )
	FROM PLIC_Y1
	WHERE MemberMci_IDNO = @An_MemberMci_IDNO
		AND OthpLicAgent_IDNO = @Ln_OthpLicAgent_IDNO
		AND LicenseStatus_CODE = @Lc_LicenseStatusI_CODE
		AND EndValidity_DATE = @Ld_High_DATE
		AND SuspLicense_DATE <> @Ld_High_DATE
		AND ExpireLicense_DATE = @Ld_High_DATE;
		
 END; --End Of PLIC_RETRIEVE_S11    

GO
