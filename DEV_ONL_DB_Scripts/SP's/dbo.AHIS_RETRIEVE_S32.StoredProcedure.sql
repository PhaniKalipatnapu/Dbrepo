/****** Object:  StoredProcedure [dbo].[AHIS_RETRIEVE_S32]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AHIS_RETRIEVE_S32] (
 @An_MemberMci_IDNO      NUMERIC(10, 0),
 @Ac_TypeAddress_CODE	 CHAR(1),
 @As_Line1_ADDR          VARCHAR(50) OUTPUT,
 @As_Line2_ADDR          VARCHAR(50) OUTPUT,
 @Ac_City_ADDR			 CHAR(28) OUTPUT,
 @Ac_State_ADDR			 CHAR(2) OUTPUT,
 @Ac_Zip_ADDR			 CHAR(15) OUTPUT,
 @Ac_Country_ADDR		 CHAR(2) OUTPUT,
 @Ad_Begin_DATE          DATE OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : AHIS_RETRIEVE_S32    
  *     DESCRIPTION       : Retrieving address details.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 12-AUG-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  SELECT @As_Line1_ADDR = NULL,
		 @As_Line2_ADDR = NULL,
         @Ac_City_ADDR = NULL,
         @Ac_State_ADDR = NULL,
         @Ac_Zip_ADDR = NULL,
         @Ac_Country_ADDR = NULL,
         @Ad_Begin_DATE = NULL;

  DECLARE @Lc_StatusGood_CODE	CHAR(1) = 'Y',
		@Lc_StatusPending_CODE	CHAR(1) = 'P',
		@Ld_High_DATE DATE = '12/31/9999';

	SELECT @As_Line1_ADDR =  Line1_ADDR,
		@As_Line2_ADDR =  Line2_ADDR,
		@Ac_City_ADDR = City_ADDR,
		@Ac_State_ADDR = State_ADDR,
		@Ac_Zip_ADDR = Zip_ADDR,
		@Ac_Country_ADDR = Country_ADDR,
		@Ad_Begin_DATE = Begin_DATE
	FROM AHIS_Y1
	WHERE MemberMci_IDNO = @An_MemberMci_IDNO
		AND TypeAddress_CODE = @Ac_TypeAddress_CODE
		AND Status_CODE IN (@Lc_StatusGood_CODE, @Lc_StatusPending_CODE)
		AND End_DATE = @Ld_High_DATE;
   
 END; -- End of AHIS_RETRIEVE_S32

GO
