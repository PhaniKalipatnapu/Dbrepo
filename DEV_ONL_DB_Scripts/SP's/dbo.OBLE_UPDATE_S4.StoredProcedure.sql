/****** Object:  StoredProcedure [dbo].[OBLE_UPDATE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OBLE_UPDATE_S4]  

	(   
     @An_Case_IDNO						NUMERIC(6,0),
     @An_OrderSeq_NUMB					NUMERIC(2,0),
     @An_ObligationSeq_NUMB		        NUMERIC(2,0),
     @Ad_BeginObligation_DATE		    DATE,
     @An_EventGlobalEndSeq_NUMB    		NUMERIC(19,0)
    )   
AS

/*
 *     PROCEDURE NAME    : OBLE_UPDATE_S4
 *     DESCRIPTION       : This procedure is used to update the Obligation info in the OBLE_Y1 Table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 21-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
		DECLARE @Ld_High_DATE           DATE = '12/31/9999',
				@Ld_Current_DATE        DATE = dbo.BATCH_COMMON_SCALAR$SF_GET_SYS_DATE_TIME(),
				@Ln_RowsAffected_NUMB   NUMERIC(10);
     
     UPDATE OBLE_Y1
        SET EventGlobalEndSeq_NUMB	= @An_EventGlobalEndSeq_NUMB, 
            EndValidity_DATE		= @Ld_Current_DATE
      WHERE Case_IDNO				= @An_Case_IDNO 
        AND OrderSeq_NUMB			= @An_OrderSeq_NUMB 
        AND ObligationSeq_NUMB		= @An_ObligationSeq_NUMB 
        AND BeginObligation_DATE	= @Ad_BeginObligation_DATE 
        AND EventGlobalBeginSeq_NUMB != @An_EventGlobalEndSeq_NUMB
        AND EndValidity_DATE		= @Ld_High_DATE;

        
		SET @Ln_RowsAffected_NUMB=@@ROWCOUNT;
		SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
		
END;--End of OBLE_UPDATE_S4


GO
