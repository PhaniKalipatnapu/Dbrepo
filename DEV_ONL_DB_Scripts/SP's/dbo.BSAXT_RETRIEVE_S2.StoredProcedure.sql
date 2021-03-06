/****** Object:  StoredProcedure [dbo].[BSAXT_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAXT_RETRIEVE_S2] (
	@Ac_TypeComponent_CODE			CHAR(4),
	@Ad_ReviewFrom_DATE				DATE			OUTPUT,
	@Ad_ReviewTo_DATE				DATE			OUTPUT,
	@An_SampleSize_QNTY				NUMERIC(7,0)	OUTPUT,
	@Ac_WorkerUpdate_ID				CHAR(30)		OUTPUT,
	@Ad_Request_DATE				DATE			OUTPUT,
	@An_TransactionEventSeq_NUMB	NUMERIC(19,0)	OUTPUT
)
AS
/*
 *     PROCEDURE NAME    : BSAXT_RETRIEVE_S2
 *     DESCRIPTION       : This procedure is used to retrieve the pending records from extract table.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 16-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1 
 */
BEGIN
	
	 SELECT @Ad_ReviewFrom_DATE				= NULL,	
			@Ad_ReviewTo_DATE				= NULL,	
			@An_SampleSize_QNTY				= NULL,
			@Ac_WorkerUpdate_ID				= NULL,
			@Ad_Request_DATE				= NULL,
			@An_TransactionEventSeq_NUMB	= NULL;
				
    DECLARE @Ld_High_DATE			DATE	= '12/31/9999',
			@Ld_Current_DATE		DATE	= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

	 SELECT @Ad_ReviewFrom_DATE				= b.ReviewFrom_DATE, 
			@Ad_ReviewTo_DATE				= b.ReviewTo_DATE, 
			@An_SampleSize_QNTY				= b.SampleSize_QNTY,
            @Ac_WorkerUpdate_ID				= b.WorkerUpdate_ID, 
            @Ad_Request_DATE				= b.Request_DATE,
            @An_TransactionEventSeq_NUMB	= b.TransactionEventSeq_NUMB
       FROM BSAXT_Y1 b
      WHERE b.TypeComponent_CODE	= @Ac_TypeComponent_CODE       
        AND b.Request_DATE			<= @Ld_Current_DATE
        AND b.EndValidity_DATE		= @Ld_High_DATE;
        
END  -- END OF BSAXT_RETRIEVE_S2


GO
