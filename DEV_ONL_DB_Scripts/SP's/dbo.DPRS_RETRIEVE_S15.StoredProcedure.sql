/****** Object:  StoredProcedure [dbo].[DPRS_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DPRS_RETRIEVE_S15] ( 
     @Ac_TypePerson_CODE			CHAR(3),
     @Ac_File_ID					CHAR(10),
     @An_DocketPerson_IDNO			NUMERIC(10,0),
	 @An_AssociatedMemberMci_IDNO	NUMERIC(10,0),
     @Ac_Exists_INDC				CHAR(1)	OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : DPRS_RETRIEVE_S15
 *     DESCRIPTION       : Checking Whether File person exists under a File_ID with the given Role in Docket Person Table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

BEGIN

	DECLARE @Ld_High_DATE 	DATE	= '12/31/9999',
			@Lc_No_TEXT		CHAR(1)	= 'N',
		  	@Lc_Yes_TEXT	CHAR(1)	= 'Y';
		  	
	SET @Ac_Exists_INDC = @Lc_No_TEXT;
	
	SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
	FROM DPRS_Y1 D
	WHERE D.File_ID = @Ac_File_ID 
	AND D.DocketPerson_IDNO = ISNULL(@An_DocketPerson_IDNO,D.DocketPerson_IDNO)
	AND D.TypePerson_CODE = ISNULL(@Ac_TypePerson_CODE,D.TypePerson_CODE)
	AND D.AssociatedMemberMci_IDNO = ISNULL(@An_AssociatedMemberMci_IDNO,D.AssociatedMemberMci_IDNO)
	AND D.EndValidity_DATE = @Ld_High_DATE 
	AND D.EffectiveEnd_DATE = @Ld_High_DATE;

                  
END; --END OF DPRS_RETRIEVE_S15


GO
