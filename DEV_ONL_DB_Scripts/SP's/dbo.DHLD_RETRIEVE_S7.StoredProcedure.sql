/****** Object:  StoredProcedure [dbo].[DHLD_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DHLD_RETRIEVE_S7]
(
	@Ac_Worker_ID           CHAR(30),
	@An_County_IDNO         NUMERIC(3, 0),
	@Ac_OrderOfDisplay_TEXT CHAR(4),
	@An_Case_IDNO           NUMERIC(6, 0),
	@Ac_CheckRecipient_ID   CHAR(10),
	@Ac_CheckRecipient_CODE CHAR(1),
	@Ac_ReasonStatus_CODE   CHAR(4),
	@Ad_From_DATE           DATE,
	@Ad_To_DATE             DATE,
	@Ac_ReleasePeriod_CODE  CHAR(5),
	@Ai_RowFrom_NUMB        INT,
	@Ai_RowTo_NUMB          INT
)
AS
/*
  *     PROCEDURE NAME    : DHLD_RETRIEVE_S7
  *     DESCRIPTION       : Retrieve the Log Disbursement Hold details for a Case Idno, Case Status, Status Code, Country Code,
 							Check Recipient Indo, Check Recipient Code, and Case Idno in a Descending Order of Release Date.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
BEGIN
	DECLARE
		@Lc_StatusCaseOpen_CODE         CHAR(1) = 'O',
		@Lc_StatusCodeHeld_TEXT         CHAR(1) = 'H',
		@Lc_Empty_TEXT					CHAR(1) = '',
		@Ld_High_DATE                   DATE = '12/31/9999',
		@Ld_Current_DATE				DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
		
	DECLARE
	   @Ls_ParameterDefination_TEXT     NVARCHAR(MAX) = ' ',    
		@Ls_OuterSelect_TEXT			NVARCHAR(MAX) = ' ',
		@Ls_InnerSelect_TEXT			NVARCHAR(MAX) = ' ',
		@Ls_WhereAppend_TEXT			NVARCHAR(MAX) = ' ',
		@Ls_ReleasePeriod_TEXT			NVARCHAR(MAX) = ' ',
		@Ls_EndSelect_TEXT				NVARCHAR(MAX) = ' ',
		@Ls_Query_TEXT					NVARCHAR(MAX) = ' ';
		
	 SET @Ls_ParameterDefination_TEXT = N' @Ac_Worker_ID           CHAR(30),
										@An_County_IDNO         NUMERIC(3, 0),
										@Ac_OrderOfDisplay_TEXT CHAR(4),
										@An_Case_IDNO           NUMERIC(6, 0),
										@Ac_CheckRecipient_ID   CHAR(10),
										@Ac_CheckRecipient_CODE CHAR(1),
										@Ac_ReasonStatus_CODE   CHAR(4),
										@Ad_From_DATE           DATE,
										@Ad_To_DATE             DATE,
										@Ac_ReleasePeriod_CODE  CHAR(5),
										@Ai_RowFrom_NUMB        INT,
										@Ai_RowTo_NUMB          INT ,
										@Lc_StatusCaseOpen_CODE CHAR(1),
										@Lc_StatusCodeHeld_TEXT CHAR(1),
										@Ld_High_DATE            DATE,
										@Ld_Current_DATE         DATE';
	
										
SET @Ls_OuterSelect_TEXT =
		'SELECT Y.CheckRecipient_ID,
		 Y.CheckRecipient_CODE,
		 Y.Case_IDNO,
		 Y.ReasonStatus_CODE,
		 Y.Transaction_DATE,
		 Y.Transaction_AMNT,
		 Y.Batch_DATE,
		 Y.SourceBatch_CODE,
		 Y.Batch_NUMB,
		 Y.SeqReceipt_NUMB,
		 Y.Release_DATE,
		 Y.Worker_ID,
		 Y.County_IDNO,
		 Y.EventGlobalBeginSeq_NUMB,
		 Y.RowCount_NUMB,
		 Y.Total_AMNT
		 FROM (SELECT X.CheckRecipient_ID,
			X.CheckRecipient_CODE,
			X.Case_IDNO,
			X.ReasonStatus_CODE,
			X.Transaction_DATE,
			X.Transaction_AMNT,
			X.Batch_DATE,
			X.SourceBatch_CODE,
			X.Batch_NUMB,
			X.SeqReceipt_NUMB,
			X.Release_DATE,
			X.Worker_ID,
			X.County_IDNO,
			X.EventGlobalBeginSeq_NUMB,
			X.RowCount_NUMB,
			X.Total_AMNT,
			X.ORD_ROWNUM
			FROM ( ';
			
	SET @Ls_InnerSelect_TEXT =
		'SELECT B.CheckRecipient_ID,
			B.CheckRecipient_CODE,
			B.Case_IDNO,
			B.ReasonStatus_CODE,
			B.Transaction_DATE,
			B.Transaction_AMNT,
			B.Batch_DATE,
			B.SourceBatch_CODE,
			B.Batch_NUMB,
			B.SeqReceipt_NUMB,
			B.Release_DATE,
			C.Worker_ID,
			A.County_IDNO,
			B.EventGlobalBeginSeq_NUMB,
			COUNT(1) OVER() AS RowCount_NUMB,
			SUM(B.Transaction_AMNT) OVER() AS Total_AMNT,
			ROW_NUMBER() OVER ( ORDER BY B.Release_DATE ' + ISNULL(@Ac_OrderOfDisplay_TEXT ,@Lc_Empty_TEXT) + ', B.Batch_DATE, B.SourceBatch_CODE, B.Batch_NUMB, B.SeqReceipt_NUMB, B.Unique_IDNO ) AS ORD_ROWNUM
            FROM
				CASE_Y1 A,
                DHLD_Y1 B,
                GLEV_Y1 C
                WHERE
					A.Worker_ID = @Ac_Worker_ID  AND
					A.County_IDNO = @An_County_IDNO AND
                    A.StatusCase_CODE = @Lc_StatusCaseOpen_CODE  AND
                    A.Case_IDNO = B.Case_IDNO AND
                    B.Status_CODE = @Lc_StatusCodeHeld_TEXT AND
                    B.EndValidity_DATE =  @Ld_High_DATE AND
                    C.EventGlobalSeq_NUMB = B.EventGlobalBeginSeq_NUMB ';

	IF @An_Case_IDNO IS NOT NULL
	BEGIN
		SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +
			' AND A.CASE_IDNO = @An_Case_IDNO';
	END
	
	IF @Ac_CheckRecipient_ID IS NOT NULL
	BEGIN
		SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +
			' AND B.CheckRecipient_ID = Ac_CheckRecipient_ID ';
	END
	
	IF @Ac_CheckRecipient_CODE IS NOT NULL
	BEGIN
		SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +
			' AND B.CheckRecipient_CODE =  @Ac_CheckRecipient_CODE ';
	END
	
	IF @Ac_ReasonStatus_CODE IS NOT NULL
	BEGIN
		SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +
			' AND B.ReasonStatus_CODE = @Ac_ReasonStatus_CODE ';
	END

	IF @Ad_From_DATE IS NOT NULL AND @Ad_To_DATE IS NOT NULL
	BEGIN
		SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT +
			' AND B.Release_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE';
	END
	
	IF @Ac_ReleasePeriod_CODE IS NOT NULL
	BEGIN
		IF @Ac_ReleasePeriod_CODE = '1'
		BEGIN
			SET @Ls_ReleasePeriod_TEXT = 
				' AND B.Release_DATE BETWEEN CONVERT(VARCHAR(10), @Ld_Current_DATE, 111) AND DATEADD(dd, 1, CONVERT(VARCHAR(10), @Ld_Current_DATE, 111) ) ';
		END
		ELSE IF @Ac_ReleasePeriod_CODE = '2'
		BEGIN
			SET @Ls_ReleasePeriod_TEXT = 
				' AND B.Release_DATE BETWEEN DATEADD(dd, 2, CONVERT(VARCHAR(10), @Ld_Current_DATE, 111) ) AND DATEADD(dd, 10, CONVERT(VARCHAR(10), @Ld_Current_DATE, 111)) ';
		END
		ELSE IF @Ac_ReleasePeriod_CODE = '11'
		BEGIN
			SET @Ls_ReleasePeriod_TEXT = 
				' AND B.Release_DATE BETWEEN DATEADD(dd, 11,  CONVERT(VARCHAR(10), @Ld_Current_DATE, 111) ) AND DATEADD(dd, 30,  CONVERT(VARCHAR(10), @Ld_Current_DATE, 111)) ';
		END
		ELSE IF @Ac_ReleasePeriod_CODE = '30'
		BEGIN
			SET @Ls_ReleasePeriod_TEXT = 
				' AND B.Release_DATE BETWEEN DATEADD(dd, 31,  CONVERT(VARCHAR(10), @Ld_Current_DATE, 111) ) AND DATEADD(dd, 60,  CONVERT(VARCHAR(10), @Ld_Current_DATE, 111) ) ';
		END
		ELSE IF @Ac_ReleasePeriod_CODE = '60'
		BEGIN
			SET @Ls_ReleasePeriod_TEXT = 
				' AND B.Release_DATE > DATEADD(dd, 60,  CONVERT(VARCHAR(10), @Ld_Current_DATE, 111) ) ';
		END
		ELSE IF @Ac_ReleasePeriod_CODE = 'S'
		BEGIN
			SET @Ls_ReleasePeriod_TEXT = 
				' AND B.Release_DATE >= DATEADD(dd, 1, CONVERT(VARCHAR(10), @Ld_Current_DATE, 111) ) ';
		END
		
		SET @Ls_WhereAppend_TEXT = @Ls_WhereAppend_TEXT + @Ls_ReleasePeriod_TEXT;
	END
	
	SET @Ls_EndSelect_TEXT =
		' ) X
			WHERE X.ORD_ROWNUM <=  @Ai_RowTo_NUMB OR @Ai_RowTo_NUMB = 0 ) Y
		WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB
		ORDER BY ORD_ROWNUM ';
	
	SET @Ls_Query_TEXT = 
					@Ls_OuterSelect_TEXT +
					@Ls_InnerSelect_TEXT +
					@Ls_WhereAppend_TEXT +
					@Ls_EndSelect_TEXT;
	


 EXEC SP_EXECUTESQL
 @Ls_Query_TEXT,
 @Ls_ParameterDefination_TEXT,
 @Ac_Worker_ID           =   @Ac_Worker_ID           ,
@An_County_IDNO         =  	@An_County_IDNO         ,
@Ac_OrderOfDisplay_TEXT =  	@Ac_OrderOfDisplay_TEXT ,
@An_Case_IDNO           =  	@An_Case_IDNO           ,
@Ac_CheckRecipient_ID   =  	@Ac_CheckRecipient_ID   ,
@Ac_CheckRecipient_CODE =  	@Ac_CheckRecipient_CODE ,
@Ac_ReasonStatus_CODE   =  	@Ac_ReasonStatus_CODE   ,
@Ad_From_DATE           =  	@Ad_From_DATE           ,
@Ad_To_DATE             =  	@Ad_To_DATE             ,
@Ac_ReleasePeriod_CODE  =  	@Ac_ReleasePeriod_CODE  ,
@Ai_RowFrom_NUMB        =  	@Ai_RowFrom_NUMB        ,
@Ai_RowTo_NUMB          =  	@Ai_RowTo_NUMB          ,
@Lc_StatusCaseOpen_CODE =   @Lc_StatusCaseOpen_CODE,
@Lc_StatusCodeHeld_TEXT =  @Lc_StatusCodeHeld_TEXT,
@Ld_High_DATE           = @Ld_High_DATE,
@Ld_Current_DATE        = @Ld_Current_DATE;
    
END
GO
