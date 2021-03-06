/****** Object:  StoredProcedure [dbo].[BSAXT_UPDATE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAXT_UPDATE_S2] 
(
	@Ac_TypeComponent_CODE			CHAR(4),
	@Ac_StatusExtract_CODE			CHAR(1),
	@An_TransactionEventSeq_NUMB	NUMERIC(19,0),
	@An_TransactionEventSeqNew_NUMB	NUMERIC(19,0),
	@An_UniverseSize_QNTY			NUMERIC(7,0)
)
AS
/*
 *     PROCEDURE NAME    : BSAXT_UPDATE_S2
 *     DESCRIPTION       : This procedure is used to End date the pending records and insert the complete records into the extract table.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 20-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
	DECLARE @Ld_High_DATE				DATE    = '12/31/9999',
			@Ld_Current_DATE			DATE	= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

	 UPDATE BSAXT_Y1
	    SET EndValidity_DATE				= @Ld_Current_DATE
	 OUTPUT deleted.Component_NAME,
			deleted.TypeComponent_CODE,
			deleted.ReviewFrom_DATE,
			deleted.ReviewTo_DATE,
			deleted.SampleSize_QNTY,
			deleted.Request_DATE,
			@Ac_StatusExtract_CODE			AS StatusExtract_CODE,
			deleted.WorkerExtract_ID,
			deleted.WorkerUpdate_ID,
			@Ld_Current_DATE				AS BeginValidity_DATE,
			@Ld_High_DATE					AS EndValidity_DATE,
			@Ld_Current_DATE				AS Update_DTTM,
			@An_TransactionEventSeqNew_NUMB	AS TransactionEventSeq_NUMB,
			@An_UniverseSize_QNTY			AS UniverseSize_QNTY,
			deleted.SummaryGenerated_INDC,
			deleted.EfficiencyRate_NUMB
	   INTO BSAXT_Y1
	  WHERE TypeComponent_CODE			= @Ac_TypeComponent_CODE
	    AND EndValidity_DATE			= @Ld_High_DATE
	    AND TransactionEventSeq_NUMB	= @An_TransactionEventSeq_NUMB;
	
	DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);
	      		  
	    SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;  
	      
	 SELECT @Ln_RowsAffected_NUMB;  

END  -- END OF BSAXT_UPDATE_S2
GO
