/****** Object:  StoredProcedure [dbo].[RO157_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RO157_RETRIEVE_S3]
	(
			@Ad_BeginFiscal_DATE	DATE,
			@Ad_EndFiscal_DATE		DATE,
			@Ac_TypeReport_CODE		CHAR(1),
			@An_County_IDNO			NUMERIC(3,0),
			@Ac_Worker_ID			CHAR(30)
	)			
AS  
  /*  
 *     PROCEDURE NAME    : RO157_RETRIEVE_S3   
 *     DESCRIPTION       : Retrieve the OCSE 157 summary details
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 27-NOV-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
	BEGIN  
	 SELECT B.BeginFiscal_DATE, 
			B.EndFiscal_DATE,
			B.TypeReport_CODE, 
			B.LineNo_TEXT,
            ROUND(B.Total,0) AS Tot_QNTY,  
            ROUND(B.ca,0) AS Ca_AMNT,  
            ROUND(B.fa,0) AS Fa_AMNT,  
            ROUND(B.na,0) AS Na_AMNT  
       FROM (SELECT A.BeginFiscal_DATE, 
					A.EndFiscal_DATE, 
					A.TypeReport_CODE, 
					A.LineNo_TEXT,
					A.Total,
					A.ca,  
					A.fa,  
					A.na, 
					COUNT(1) OVER () AS ln_count
			   FROM (SELECT R.BeginFiscal_DATE, 
							R.EndFiscal_DATE, 
							R.TypeReport_CODE, 
							R.LineNo_TEXT,
							SUM (R.Tot_QNTY) Total, 
							SUM (R.Ca_AMNT) ca, 
							SUM (R.Fa_AMNT) fa, 
							SUM (R.Na_AMNT) na
					   FROM	RO157_Y1 R
					  WHERE R.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
						AND R.EndFiscal_DATE = @Ad_EndFiscal_DATE
						AND R.TypeReport_CODE = @Ac_TypeReport_CODE
						AND R.County_IDNO = ISNULL(@An_County_IDNO,R.County_IDNO)
						AND R.Worker_ID = ISNULL(@Ac_Worker_ID,R.Worker_ID)
				   GROUP BY R.BeginFiscal_DATE, R.EndFiscal_DATE, R.TypeReport_CODE, R.LineNo_TEXT 
					) A
            ) B;
                   
  END; --- End of RO157_RETRIEVE_S3

GO
