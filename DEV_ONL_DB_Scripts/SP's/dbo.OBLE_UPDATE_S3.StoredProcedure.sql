/****** Object:  StoredProcedure [dbo].[OBLE_UPDATE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_UPDATE_S3] 
	(
     @An_Case_IDNO						NUMERIC(6,0),
     @An_OrderSeq_NUMB					NUMERIC(2,0),
     @An_ObligationSeq_NUMB				NUMERIC(2,0),
     @An_EventGlobalBeginSeq_NUMB	    NUMERIC(19,0),
     @An_MemberMci_IDNO					NUMERIC(10,0),
     @Ac_Fips_CODE						CHAR(7),
     @Ac_CheckRecipient_ID				CHAR(10),
     @Ac_CheckRecipient_CODE			CHAR(1)       
    )
AS

/*
 *     PROCEDURE NAME    : OBLE_UPDATE_S3
 *     DESCRIPTION       : This procedure is used to update the Obligation info in the OBLE_Y1 Table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 24-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/   BEGIN
		DECLARE
			 @Ld_Current_DATE		DATE	= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
			 @Ld_High_DATE          DATE    = '12/31/9999',
			 @Ln_RowsAffected_NUMB  NUMERIC(10);
			 
      UPDATE OBLE_Y1
         SET Fips_CODE				  = @Ac_Fips_CODE, 
             CheckRecipient_ID		  = @Ac_CheckRecipient_ID, 
             CheckRecipient_CODE	  = @Ac_CheckRecipient_CODE, 
             EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB, 
             BeginValidity_DATE		  = @Ld_Current_DATE     
      OUTPUT     
            DELETED.Case_IDNO,
			DELETED.OrderSeq_NUMB,
			DELETED.ObligationSeq_NUMB,
			DELETED.MemberMci_IDNO,
			DELETED.TypeDebt_CODE,
			DELETED.Fips_CODE,
			DELETED.FreqPeriodic_CODE,
			DELETED.Periodic_AMNT,
			DELETED.ExpectToPay_AMNT,
			DELETED.ExpectToPay_CODE,
			DELETED.ReasonChange_CODE,
			DELETED.BeginObligation_DATE,
			DELETED.EndObligation_DATE,
			DELETED.AccrualLast_DATE,
			DELETED.AccrualNext_DATE,
			DELETED.CheckRecipient_ID,
			DELETED.CheckRecipient_CODE,
			DELETED.EventGlobalBeginSeq_NUMB,
			@An_EventGlobalBeginSeq_NUMB AS EventGlobalEndSeq_NUMB,
			DELETED.BeginValidity_DATE,
			@Ld_Current_DATE AS EndValidity_DATE        
      WHERE Case_IDNO			 = @An_Case_IDNO 
        AND OrderSeq_NUMB		 = @An_OrderSeq_NUMB 
        AND ObligationSeq_NUMB   = @An_ObligationSeq_NUMB
        AND EndValidity_DATE	 = @Ld_High_DATE
        AND Membermci_IDNO		 = @An_Membermci_IDNO;      
        
          SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
       SELECT @Ln_RowsAffected_NUMB AS  RowsAffected_NUMB;

END; --END OF OBLE_UPDATE_S3


GO
