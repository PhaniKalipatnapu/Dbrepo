/****** Object:  StoredProcedure [dbo].[BSAXT_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAXT_INSERT_S1]
(
	@As_Component_NAME				VARCHAR(50),
	@Ac_TypeComponent_CODE			CHAR(4),
	@Ad_ReviewFrom_DATE				DATE,
	@Ad_ReviewTo_DATE				DATE,
	@An_SampleSize_QNTY				NUMERIC(7,0),
	@Ac_StatusExtract_CODE			CHAR(1),
	@Ac_SignedOnWorker_ID			CHAR(30),
	@An_TransactionEventSeq_NUMB	NUMERIC(19,0),
	@An_UniverseSize_QNTY			NUMERIC(7,0),
	@Ac_SummaryGenerated_INDC		CHAR(1),
	@An_EfficiencyRate_NUMB			NUMERIC(3,0)
)
AS
/*
 *     PROCEDURE NAME    : BSAXT_INSERT_S1
 *     DESCRIPTION       : This procedure is used to insert the screen input details into extract table.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 25-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN

   DECLARE @Ld_High_DATE				DATE	 = '12/31/9999',
           @Ld_Current_DATE				DATE	 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

	INSERT INTO BSAXT_Y1
				(Component_NAME,
				 TypeComponent_CODE,
				 ReviewFrom_DATE,
				 ReviewTo_DATE,
				 SampleSize_QNTY,
				 Request_DATE,
				 StatusExtract_CODE,
				 Workerextract_ID,
				 WorkerUpdate_ID,
				 BeginValidity_DATE,
				 EndValidity_DATE,
				 Update_DTTM,
				 TransactionEventSeq_NUMB,
				 UniverseSize_QNTY,
				 SummaryGenerated_INDC,
				 EfficiencyRate_NUMB		
				)
		VALUES (@As_Component_NAME,				-- Component_NAME
				@Ac_TypeComponent_CODE,			-- TypeComponent_CODE
				@Ad_ReviewFrom_DATE,			-- ReviewFrom_DATE
				@Ad_ReviewTo_DATE,				-- ReviewTo_DATE
				@An_SampleSize_QNTY,			-- SampleSize_QNTY
				@Ld_Current_DATE,				-- Request_DATE
				@Ac_StatusExtract_CODE,			-- StatusExtract_CODE
				@Ac_SignedOnWorker_ID,			-- Workerextract_ID
				@Ac_SignedOnWorker_ID,			-- WorkerUpdate_ID
				@Ld_Current_DATE,				-- BeginValidity_DATE
				@Ld_High_DATE,					-- EndValidity_DATE
				@Ld_Current_DATE,				-- Update_DTTM
				@An_TransactionEventSeq_NUMB,	-- TransactionEventSeq_NUMB
				@An_UniverseSize_QNTY,			-- UniverseSize_QNTY
				@Ac_SummaryGenerated_INDC,		-- SummaryGenerated_INDC
				@An_EfficiencyRate_NUMB			-- EfficiencyRate_NUMB
				);

END  --END OF BSAXT_INSERT_S1


GO
