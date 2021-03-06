/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S32]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE 
	[dbo].[FDEM_RETRIEVE_S32]  
		(
			 @Ac_TypeDoc_CODE				CHAR(1),
			 @An_Document_IDNO				NUMERIC(15),
			 @Ac_DocReference_CODE			CHAR(4),
			 @Ac_Exists_INDC				CHAR(1)		OUTPUT
		)
AS

/*
 *     PROCEDURE NAME    : FDEM_RETRIEVE_S32
 *     DESCRIPTION       : Check the existance of Document Number based on Document type
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 24-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
   
      DECLARE
         @Lc_TypeDocP_CODE	CHAR(1)	=	'P' ,
         @Lc_TypeDocO_CODE	CHAR(1)	=	'O',
         @Lc_Yes_INDC		CHAR(1)	=	'Y',
		 @Lc_No_INDC		CHAR(1) =	'N',
         @Ld_High_DATE		DATE	= '12/31/9999';
         
      SET 
		@Ac_Exists_INDC = @Lc_No_INDC ;
        
		SELECT @Ac_Exists_INDC = @Lc_Yes_INDC
		 FROM FDEM_Y1 F
		WHERE ( (	@Ac_TypeDoc_CODE = @Lc_TypeDocP_CODE
				AND F.Petition_IDNO=@An_Document_IDNO
				)
			 OR (	@Ac_TypeDoc_CODE = @Lc_TypeDocO_CODE
				AND F.Order_IDNO=@An_Document_IDNO
				)
			)
		AND F.DocReference_CODE = @Ac_DocReference_CODE
        AND	F.EndValidity_DATE = @Ld_High_DATE;
                  
END;	--END OF FDEM_RETRIEVE_S32


GO
