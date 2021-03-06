/****** Object:  StoredProcedure [dbo].[OBLE_UPDATE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OBLE_UPDATE_S6]  

 (   
     @An_Case_IDNO						NUMERIC(6,0),
     @An_OrderSeq_NUMB					NUMERIC(2,0),
     @An_ObligationSeq_NUMB		        NUMERIC(2,0)
  )   
AS

/*
 *     PROCEDURE NAME    : OBLE_UPDATE_S6
 *     DESCRIPTION       : This procedure is used to update the Obligation records in OBLE_Y1.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 21-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
		DECLARE 
			@Ld_High_DATE           DATE = '12/31/9999',
			@Ld_Current_DATE        DATE =  dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
			@Ln_RowsAffected_NUMB   NUMERIC(10); 
     
		UPDATE OBLE_Y1
			SET AccrualNext_DATE = BeginObligation_DATE
		WHERE   Case_IDNO = @An_Case_IDNO 
			AND OrderSeq_NUMB = @An_OrderSeq_NUMB 
			AND ObligationSeq_NUMB = @An_ObligationSeq_NUMB 
			AND BeginObligation_DATE > @Ld_Current_DATE 
			AND EndValidity_DATE = @Ld_High_DATE;
      
				
			SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
			
			SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
			
END;--END OF OBLE_UPDATE_S6


GO
