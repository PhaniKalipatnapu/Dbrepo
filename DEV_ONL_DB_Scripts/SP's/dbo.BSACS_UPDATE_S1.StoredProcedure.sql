/****** Object:  StoredProcedure [dbo].[BSACS_UPDATE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSACS_UPDATE_S1]
(
	@An_Case_IDNO					NUMERIC(6,0),
	@Ad_Review_DATE					DATE,
	@Ac_CaseClosure_INDC			CHAR(1),
	@Ac_Establishment_INDC			CHAR(1),
	@Ac_SecEnfmedical_INDC			CHAR(1),
	@Ac_Enfsuporder_INDC			CHAR(1),
	@Ac_Disbcollections_INDC		CHAR(1),
	@Ac_Expeditedprocess_INDC		CHAR(1),
	@Ac_ReviewAdjustment_INDC		CHAR(1),
	@Ac_InterstateOutgoing_INDC		CHAR(1)	
)
AS
/*
 *     PROCEDURE NAME    : BSACS_UPDATE_S1
 *     DESCRIPTION       : This procedure is used to update the indication for the specific component
						   according to the given case id.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 27-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
	
	UPDATE BSACS_Y1
       SET CaseClosure_INDC			= @Ac_CaseClosure_INDC,
		   Establishment_INDC		= @Ac_Establishment_INDC,
		   SecEnfmedical_INDC		= @Ac_SecEnfmedical_INDC,
		   Enfsuporder_INDC			= @Ac_Enfsuporder_INDC,
		   Disbcollections_INDC		= @Ac_Disbcollections_INDC,
		   Expeditedprocess_INDC	= @Ac_Expeditedprocess_INDC,
		   ReviewAdjustment_INDC	= @Ac_ReviewAdjustment_INDC,
		   InterstateOutgoing_INDC	= @Ac_InterstateOutgoing_INDC
     WHERE Case_IDNO = @An_Case_IDNO
       AND Review_DATE = @Ad_Review_DATE;       
	
	DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);
	      		  
	    SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;  
	      
	 SELECT @Ln_RowsAffected_NUMB;  

END  -- END OF BSACS_UPDATE_S1
GO
