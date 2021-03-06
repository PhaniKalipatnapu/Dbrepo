/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S24]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S24]  
(
     @An_Case_IDNO						NUMERIC(6,0),
     @Ac_IVDOutOfStateCountyFips_CODE	CHAR(3)	 OUTPUT,
     @Ac_IVDOutOfStateOfficeFips_CODE	CHAR(2)	 OUTPUT,
     @Ac_IVDOutOfStateFips_CODE			CHAR(2)	 OUTPUT,
     @Ac_IVDOutOfStateCase_ID			CHAR(15) OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : ICAS_RETRIEVE_S24
 *     DESCRIPTION       : Retrieves the IVD Out Of State details.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 12/06/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */

BEGIN

      SELECT @Ac_IVDOutOfStateCountyFips_CODE = NULL,
             @Ac_IVDOutOfStateOfficeFips_CODE = NULL,
             @Ac_IVDOutOfStateFips_CODE       = NULL,
             @Ac_IVDOutOfStateCase_ID         = NULL;

     DECLARE 
		@Lc_StatusOpen_CODE	CHAR(1) = 'O' ,
		@Ld_High_DATE		DATE	= '12/31/9999';
        
      SELECT DISTINCT @Ac_IVDOutOfStateFips_CODE       = I.IVDOutOfStateFips_CODE, 
					  @Ac_IVDOutOfStateCountyFips_CODE = I.IVDOutOfStateCountyFips_CODE, 
					  @Ac_IVDOutOfStateOfficeFips_CODE = I.IVDOutOfStateOfficeFips_CODE, 
					  @Ac_IVDOutOfStateCase_ID         = I.IVDOutOfStateCase_ID
      FROM ICAS_Y1 I
      WHERE I.Case_IDNO                = @An_Case_IDNO 
		AND I.Status_CODE		= @Lc_StatusOpen_CODE
		AND I.EndValidity_DATE         = @Ld_High_DATE 
		AND I.TransactionEventSeq_NUMB = (SELECT MAX(I.TransactionEventSeq_NUMB) 
                                            FROM ICAS_Y1 I
                                           WHERE I.Case_IDNO        = @An_Case_IDNO 
                                             AND I.EndValidity_DATE = @Ld_High_DATE);
END--END OF ICAS_RETRIEVE_S24


GO
