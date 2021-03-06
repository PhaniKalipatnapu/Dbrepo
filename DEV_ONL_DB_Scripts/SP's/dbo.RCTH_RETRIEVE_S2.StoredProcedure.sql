/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S2]
(
	@Ac_Worker_ID			CHAR(30),
	@An_County_IDNO			NUMERIC(3),
	@Ac_OrderOfDisplay_TEXT CHAR(4),
	@An_Case_IDNO			NUMERIC(6),
	@An_PayorMCI_IDNO		NUMERIC(10),
	@Ac_ReasonStatus_CODE	CHAR(4),
	@Ad_From_DATE			DATE,
	@Ad_To_DATE				DATE,
	@Ac_ReleasePeriod_CODE	CHAR(2),
	@Ai_RowFrom_NUMB		INT = 1,
	@Ai_RowTo_NUMB			INT = 10
)
AS
/*
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S2
 *     DESCRIPTION       : Retrieve Receipt details for a Case Id in a Descending Order of Release Date.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
	DECLARE
		@Lc_Empty_TEXT						CHAR(1) = '',
		@Lc_StatusCaseOpen_CODE				CHAR(1) = 'O',
		@Lc_CaseRelationshipNcp_CODE		CHAR(1) = 'A',
        @Lc_CaseRelationshipPutFather_CODE	CHAR(1) = 'P',
        @Lc_StatusReceiptHeld_CODE			CHAR(1) = 'H',
        @Lc_Yes_TEXT						CHAR(1) = 'Y',
        @Ld_Current_DATE					DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
        @Ld_Low_DATE						DATE = '01/01/0001',
        @Ld_High_DATE						DATE = '12/31/9999';
        
	DECLARE
		@Ls_OuterSelect_TEXT				NVARCHAR(MAX) = ' ',
		@Ls_InnerSelect_TEXT				NVARCHAR(MAX) = ' ',
		@Ls_WhereAppend_TEXT				NVARCHAR(MAX) = ' ',
		 @Ls_ParameterDefination_TEXT    NVARCHAR(MAX) = ' ',  
		@Ls_ReleasePeriod_TEXT				NVARCHAR(MAX) = ' ',
		@Ls_EndSelect_TEXT					NVARCHAR(MAX) = ' ',
		@Ls_Query_TEXT						NVARCHAR(MAX) = ' ';
		
		
		
		SET @Ls_ParameterDefination_TEXT =N'@Ac_Worker_ID			CHAR(30),
	@An_County_IDNO			NUMERIC(3),
	@Ac_OrderOfDisplay_TEXT CHAR(4),
	@An_Case_IDNO			NUMERIC(6),
	@An_PayorMCI_IDNO		NUMERIC(10),
	@Ac_ReasonStatus_CODE	CHAR(4),
	@Ad_From_DATE			DATE,
	@Ad_To_DATE				DATE,
	@Ac_ReleasePeriod_CODE	CHAR(2),
	@Ai_RowFrom_NUMB		INT = 1,
	@Ai_RowTo_NUMB			INT = 10,
	@Lc_Empty_TEXT						CHAR(1),
	@Lc_StatusCaseOpen_CODE				CHAR(1),
	@Lc_Yes_TEXT						CHAR(1),
	@Lc_CaseRelationshipNcp_CODE		CHAR(1),
        @Lc_CaseRelationshipPutFather_CODE	CHAR(1) ,
        @Lc_StatusReceiptHeld_CODE			CHAR(1) ,
        @Ld_Low_DATE						DATE,
        @Ld_High_DATE						DATE,
	@Ld_Current_DATE         DATE';
		
	
	SET @Ls_OuterSelect_TEXT = 
		'SELECT X.Batch_DATE,
			 X.SourceBatch_CODE,
			 X.Batch_NUMB,
			 X.SeqReceipt_NUMB,
			 X.Receipt_DATE,
			 X.PayorMCI_IDNO,
			 X.Case_IDNO,
			 X.ToDistribute_AMNT,
			 X.BeginValidity_DATE,
			 X.Release_DATE,
			 X.County_IDNO,
			 X.Worker_ID,
			 X.ReasonStatus_CODE,
			 X.First_NAME,
			 X.Middle_NAME,
			 X.Last_NAME,
			 X.Suffix_NAME,
			 X.TypePosting_CODE,
			 X.EventGlobalBeginSeq_NUMB,
			 X.RowCount_NUMB,
			 X.Total_AMNT
		FROM (SELECT H.Batch_DATE,
					 H.SourceBatch_CODE,
					 H.Batch_NUMB,
					 H.SeqReceipt_NUMB,
					 H.Receipt_DATE,
					 H.PayorMCI_IDNO,
					 H.Case_IDNO,
					 H.ToDistribute_AMNT,
					 H.BeginValidity_DATE,
					 H.Release_DATE,
					 H.County_IDNO,
					 G.Worker_ID,
					 H.ReasonStatus_CODE,
					 D.First_NAME,
					 D.Middle_NAME,
					 D.Last_NAME,
					 D.Suffix_NAME,
					 H.TypePosting_CODE,
					 H.EventGlobalBeginSeq_NUMB,
					 H.RowCount_NUMB,
					 H.Total_AMNT,
					 ROW_NUMBER() OVER ( ORDER BY H.ORD_ROWNUM ) AS ORD_ROWNUM
				FROM (SELECT X.Batch_DATE,
							 X.SourceBatch_CODE,
							 X.Batch_NUMB,
							 X.SeqReceipt_NUMB,
							 X.Receipt_DATE,
							 X.PayorMCI_IDNO,
							 X.Case_IDNO,
							 X.ToDistribute_AMNT,
							 X.BeginValidity_DATE,
							 X.Release_DATE,
							 X.County_IDNO,
							 X.ReasonStatus_CODE,
							 X.TypePosting_CODE,
							 X.EventGlobalBeginSeq_NUMB,
							 X.RowCount_NUMB,
							 X.Total_AMNT,
							 X.ORD_ROWNUM
						FROM (';
	
	SET @Ls_InnerSelect_TEXT = 
		'SELECT C.Batch_DATE,
			C.SourceBatch_CODE,
			C.Batch_NUMB,
			C.SeqReceipt_NUMB,
			C.Receipt_DATE,
			C.PayorMCI_IDNO,
			C.Case_IDNO,
			C.ToDistribute_AMNT,
			C.BeginValidity_DATE,
			C.Release_DATE,
			A.County_IDNO,
			C.ReasonStatus_CODE,
			C.TypePosting_CODE,
			C.EventGlobalBeginSeq_NUMB,
			COUNT(1) OVER() AS RowCount_NUMB,
			SUM(C.ToDistribute_AMNT) OVER()AS Total_AMNT,
			ROW_NUMBER() OVER ( ORDER BY C.Release_DATE ' + ISNULL(@Ac_OrderOfDisplay_TEXT ,@Lc_Empty_TEXT) + ', C.Batch_DATE, C.SourceBatch_CODE, C.Batch_NUMB, C.SeqReceipt_NUMB, C.EventGlobalBeginSeq_NUMB ) AS ORD_ROWNUM
		FROM CASE_Y1 A,
			CMEM_Y1 B,
			RCTH_Y1 C
		WHERE A.Worker_ID = @Ac_Worker_ID  AND
			A.County_IDNO = @An_County_IDNO  AND
			A.StatusCase_CODE =  @Lc_StatusCaseOpen_CODE  AND
			B.Case_IDNO = A.Case_IDNO AND
			B.CaseRelationship_CODE IN ( @Lc_CaseRelationshipNcp_CODE ,  @Lc_CaseRelationshipPutFather_CODE ) AND
			C.PayorMCI_IDNO = b.MemberMci_IDNO AND
			C.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE  AND
			C.Distribute_DATE = @Ld_Low_DATE AND
			C.EndValidity_DATE =  @Ld_High_DATE AND
			NOT EXISTS
			(
				SELECT 1
				FROM RCTH_Y1 T
				WHERE T.Batch_DATE = C.Batch_DATE AND
					T.SourceBatch_CODE = C.SourceBatch_CODE AND
					T.Batch_NUMB = C.Batch_NUMB AND
					T.SeqReceipt_NUMB = C.SeqReceipt_NUMB AND
					T.BackOut_INDC =  @Lc_Yes_TEXT  AND
					T.EndValidity_DATE =  @Ld_High_DATE
			)';

	IF @An_Case_IDNO IS NOT NULL
	BEGIN
		SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT + 
			' AND A.Case_IDNO = @An_Case_IDNO ';
	END
	
	IF @An_PayorMCI_IDNO IS NOT NULL
	BEGIN
		SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT + 
			' AND C.PayorMCI_IDNO = @An_PayorMCI_IDNO';
	END
	
	IF @Ac_ReasonStatus_CODE IS NOT NULL
	BEGIN
		SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT + 
			' AND C.ReasonStatus_CODE = @Ac_ReasonStatus_CODE';
	END
	
	IF @Ad_From_DATE IS NOT NULL AND @Ad_To_DATE IS NOT NULL
	BEGIN
		SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT + 
			' AND C.Release_DATE BETWEEN  @Ad_From_DATE AND  @Ad_To_DATE';
	END
	
	IF @Ac_ReleasePeriod_CODE IS NOT NULL
	BEGIN
		IF @Ac_ReleasePeriod_CODE = '1'
		BEGIN
			SET @Ls_ReleasePeriod_TEXT = 
				' AND C.Release_DATE BETWEEN @Ld_Current_DATE AND DATEADD(dd, 1, @Ld_Current_DATE) ';
		END
		ELSE IF @Ac_ReleasePeriod_CODE = '2'
		BEGIN
			SET @Ls_ReleasePeriod_TEXT = 
				' AND C.Release_DATE BETWEEN DATEADD(dd, 2,  @Ld_Current_DATE  AND DATEADD(dd, 10,  @Ld_Current_DATE) ';
		END
		ELSE IF @Ac_ReleasePeriod_CODE = '11'
		BEGIN
			SET @Ls_ReleasePeriod_TEXT = 
				' AND C.Release_DATE BETWEEN DATEADD(dd, 11, @Ld_Current_DATE AND DATEADD(dd, 30, @Ld_Current_DATE) ';
		END
		ELSE IF @Ac_ReleasePeriod_CODE = '30'
		BEGIN
			SET @Ls_ReleasePeriod_TEXT = 
				' AND C.Release_DATE BETWEEN DATEADD(dd, 31, @Ld_Current_DATE) AND DATEADD(dd, 60,  @Ld_Current_DATE) ';
		END
		ELSE IF @Ac_ReleasePeriod_CODE = '60'
		BEGIN
			SET @Ls_ReleasePeriod_TEXT = 
				' AND C.Release_DATE > DATEADD(dd, 60,  @Ld_Current_DATE) ';
		END
		ELSE IF @Ac_ReleasePeriod_CODE = 'S'
		BEGIN
			SET @Ls_ReleasePeriod_TEXT = 
				' AND C.Release_DATE >= DATEADD(dd, 1, @Ld_Current_DATE) ';
		END
		
		SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT + @Ls_ReleasePeriod_TEXT;
	END
	
	SET @Ls_EndSelect_TEXT =
		') X
		WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB OR @Ai_RowTo_NUMB = 0 ) H,
			GLEV_Y1 G,
			DEMO_Y1 D
		WHERE H.PayorMCI_IDNO = D.MemberMci_IDNO
			AND H.ORD_ROWNUM >=  @Ai_RowFrom_NUMB
			AND H.EventGlobalBeginSeq_NUMB = G.EventGlobalSeq_NUMB) X';
			
	SET @Ls_Query_TEXT = 
		@Ls_OuterSelect_TEXT + 
		@Ls_InnerSelect_TEXT + 
		@Ls_WhereAppend_TEXT + 
		@Ls_EndSelect_TEXT;
	
	EXEC sp_executesql 
 @Ls_Query_TEXT,
 @Ls_ParameterDefination_TEXT,
 @Ac_Worker_ID		=@Ac_Worker_ID,
	@An_County_IDNO		=@An_County_IDNO,
	@Ac_OrderOfDisplay_TEXT =@Ac_OrderOfDisplay_TEXT,
	@An_Case_IDNO			=@An_Case_IDNO,
	@An_PayorMCI_IDNO		=@An_PayorMCI_IDNO,
	@Ac_ReasonStatus_CODE	=@Ac_ReasonStatus_CODE,
	@Ad_From_DATE			=@Ad_From_DATE,
	@Ad_To_DATE				=@Ad_To_DATE,
	@Ac_ReleasePeriod_CODE	=@Ac_ReleasePeriod_CODE,
	@Ai_RowFrom_NUMB		=@Ai_RowFrom_NUMB,
	@Ai_RowTo_NUMB			=@Ai_RowTo_NUMB,
	@Lc_Empty_TEXT	       = @Lc_Empty_TEXT,
	@Lc_StatusCaseOpen_CODE	=@Lc_StatusCaseOpen_CODE,
	@Lc_Yes_TEXT = @Lc_Yes_TEXT,
	@Ld_Current_DATE       = @Ld_Current_DATE,
	@Lc_CaseRelationshipNcp_CODE=@Lc_CaseRelationshipNcp_CODE,
	@Lc_CaseRelationshipPutFather_CODE=@Lc_CaseRelationshipPutFather_CODE,
	@Lc_StatusReceiptHeld_CODE=@Lc_StatusReceiptHeld_CODE,
	@Ld_Low_DATE=@Ld_Low_DATE,
	@Ld_High_DATE=@Ld_High_DATE;
	
 

	

END

GO
