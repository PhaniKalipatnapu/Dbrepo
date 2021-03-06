/****** Object:  StoredProcedure [dbo].[OFIC_RETRIEVE_S35]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OFIC_RETRIEVE_S35] ( 
			@Ad_Batch_DATE			DATE,
			@An_Batch_NUMB          NUMERIC(4,0),
			@An_SeqReceipt_NUMB		NUMERIC(6,0),
			@An_Office_IDNO			NUMERIC(3,0),
			@Ac_SourceBatch_CODE	CHAR(3),
			@Ac_WrkAccess_INDC      CHAR(1)	OUTPUT
		)
AS

/*
 *     PROCEDURE NAME    : OFIC_RETRIEVE_S35
 *     DESCRIPTION       : This procedue checks and returns 'Y' if the receipt distributed to a Case in a county to which worker belongs.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 01-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */BEGIN
      DECLARE @Lc_Yes_INDC		CHAR(1) = 'Y', 
			  @Ld_High_DATE		DATE	= '12/31/9999';
        
		  SET @Ac_WrkAccess_INDC = 'N';
      
       SELECT @Ac_WrkAccess_INDC = @Lc_Yes_INDC
		 FROM OFIC_Y1 a
		WHERE a.Office_IDNO		 = @An_Office_IDNO 
		  AND a.EndValidity_DATE = @Ld_High_DATE  
		  AND EXISTS (
						SELECT 1 
						  FROM LSUP_Y1 r
							   JOIN CASE_Y1 b
						    ON r.Case_IDNO		  = b.Case_IDNO 		
						 WHERE r.Batch_DATE		  = @Ad_Batch_DATE 
						   AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE 
						   AND r.Batch_NUMB		  = @An_Batch_NUMB 
						   AND r.SeqReceipt_NUMB  = @An_SeqReceipt_NUMB 
						   AND b.County_IDNO	  = a.County_IDNO );
                  
END; -- END OF OFIC_RETRIEVE_S35


GO
