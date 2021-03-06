/****** Object:  StoredProcedure [dbo].[DSBH_RETRIEVE_S21]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[DSBH_RETRIEVE_S21](
 @Ac_StatusCheck_CODE		CHAR(2)		,
 @Ac_CheckRecipient_CODE	CHAR(1)     ,
 @Ad_From_DATE				DATE		,
 @Ad_To_DATE				DATE		,
 @Ai_RowFrom_NUMB			INT=1       ,
 @Ai_RowTo_NUMB				INT=10      
 )     
AS

/*
 *     PROCEDURE NAME    : DSBH_RETRIEVE_S21
 *     DESCRIPTION       : Retrieve Summary of all Disbursements that have been Stopped or Voided for a date range.
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 01-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN
   
      DECLARE
    	  @Lc_MediumDisburseC_CODE      CHAR(1) = 'C'		, 
          @Lc_Empty_TEXT			    CHAR(1) = ''		,   
		  @Lc_Percentage_TEXT			CHAR(1) = '%' 		,
    	  @Lc_StatusCheckVS_CODE        CHAR(4) = '[VS]'	,
          @Li_Zero_NUMB					SMALLINT=  0		,
		  @Lc_CheckRecipient_ID			CHAR(9)	= '999999980' ,
		  @Ld_High_DATE					DATE	= '12/31/9999'; 
		  
		SELECT Y.StatusCheck_CODE,
		       Y.ReasonStatus_CODE,
		       Y.TotalAmount_AMNT,
		       Y.TotalCount_QNTY,
		       Y.GroupCount_QNTY,
		       Y.Value_AMNT,
		       Y.RowCount_NUMB
		  FROM (SELECT X.TotalAmount_AMNT,
		               X.TotalCount_QNTY,
		               X.Value_AMNT,
		               X.ReasonStatus_CODE,
		               X.StatusCheck_CODE,
		               X.GroupCount_QNTY,
		               X.RowCount_NUMB,
		               X.ORD_ROWNUM AS row_num
		          FROM (SELECT  x.Value_AMNT,
		          				x.ReasonStatus_CODE,
		          				x.StatusCheck_CODE,
		          				x.GroupCount_QNTY,
		          				SUM(x.GroupCount_QNTY) OVER() AS TotalCount_QNTY,
		                       	SUM(x.Value_AMNT) OVER() AS TotalAmount_AMNT,
		                       	x.RowCount_NUMB,
		                       	x.ORD_ROWNUM
                  FROM (SELECT SUM(a.Disburse_AMNT) AS Value_AMNT,
                               a.ReasonStatus_CODE,
                               a.StatusCheck_CODE,
                               COUNT(1) AS GroupCount_QNTY,
                               COUNT(1) OVER() AS RowCount_NUMB,
                               ROW_NUMBER() OVER( ORDER BY a.ReasonStatus_CODE, a.StatusCheck_CODE) AS ORD_ROWNUM
                          FROM (SELECT SUM(z.Disburse_AMNT) AS Disburse_AMNT,
                                       a.ReasonStatus_CODE,
                                       a.StatusCheck_CODE
                                  FROM DSBH_Y1 a WITH (INDEX (0))
                                       JOIN DSBL_Y1 z
                                        ON a.CheckRecipient_ID = z.CheckRecipient_ID
                                           AND a.CheckRecipient_CODE = z.CheckRecipient_CODE
                                           AND a.Disburse_DATE = z.Disburse_DATE
                                           AND a.DisburseSeq_NUMB = z.DisburseSeq_NUMB
                                 WHERE a.StatusCheck_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE
                                   AND a.MediumDisburse_CODE = @Lc_MediumDisburseC_CODE
                                   AND a.CheckRecipient_ID <> @Lc_CheckRecipient_ID
                                   AND a.StatusCheck_CODE LIKE (CASE
                                                                 WHEN @Ac_StatusCheck_CODE IS NOT NULL
                                                                  THEN LTRIM(RTRIM(@Ac_StatusCheck_CODE)) + @Lc_Percentage_TEXT
                                                                 ELSE @Lc_StatusCheckVS_CODE + @Lc_Percentage_TEXT
                                                                END)
                                   AND a.CheckRecipient_CODE = ISNULL(@Ac_CheckRecipient_CODE, a.CheckRecipient_CODE)
                                   AND a.EndValidity_DATE = @Ld_High_DATE
                                 GROUP BY a.ReasonStatus_CODE,
                                          a.StatusCheck_CODE,
                                          ISNULL(a.MediumDisburse_CODE, @Lc_Empty_TEXT),
                                          ISNULL(a.Check_NUMB, 0),
                                          ISNULL(a.Misc_ID, @Lc_Empty_TEXT),
                                          ISNULL(CAST(a.Disburse_DATE AS NVARCHAR(MAX)), @Lc_Empty_TEXT),
                                          ISNULL(CAST(a.Disburse_AMNT AS NVARCHAR(MAX)), @Lc_Empty_TEXT),
                                          ISNULL(CAST(a.StatusCheck_DATE AS NVARCHAR(MAX)), @Lc_Empty_TEXT),
                                          ISNULL(a.ReasonStatus_CODE, @Lc_Empty_TEXT),
                                          ISNULL(a.StatusCheck_CODE, @Lc_Empty_TEXT),
                                          ISNULL(a.CheckRecipient_ID, 0),
                                          ISNULL(a.CheckRecipient_CODE, @Lc_Empty_TEXT),
                                          ISNULL(z.Case_IDNO, 0)) a
                         GROUP BY a.ReasonStatus_CODE,
                                  a.StatusCheck_CODE) AS X) AS X
		         WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB
		            OR (@Ai_RowTo_NUMB = @Li_Zero_NUMB)) AS Y
		WHERE Y.row_num >= @Ai_RowFrom_NUMB
		    OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)
		ORDER BY ROW_NUM;
	                  
END; --END OF DSBH_RETRIEVE_S21


GO
