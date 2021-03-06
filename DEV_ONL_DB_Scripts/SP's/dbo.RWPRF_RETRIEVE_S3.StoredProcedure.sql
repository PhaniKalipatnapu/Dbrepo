/****** Object:  StoredProcedure [dbo].[RWPRF_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RWPRF_RETRIEVE_S3]
 (	
	@Ad_BeginFiscal_DATE	DATE,    
    @Ad_EndFiscal_DATE		DATE,
	@An_County_IDNO			NUMERIC(3,0)
)
AS  
  /*  
 *     PROCEDURE NAME    : RWPRF_RETRIEVE_S3   
 *     DESCRIPTION       : This procedure is used to Retrieve the Worker_ID and Worker_name for the County_ID.
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 16-JUL-2012  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
BEGIN
	DECLARE
		@Ld_High_DATE	DATE	= '12/31/9999';
	SELECT DISTINCT R.Worker_ID, 			  
	   	   RTRIM (b.Last_NAME) AS Last_NAME,
		   RTRIM (b.Suffix_NAME) AS Suffix_NAME,
		   RTRIM (b.First_NAME) AS First_NAME,
		   RTRIM (b.Middle_NAME) AS Middle_NAME,
		   ROW_NUMBER() OVER( ORDER BY b.Last_NAME,b.Suffix_NAME,b.First_NAME,b.Middle_NAME ASC) AS ORD_ROWNUM
      FROM RWPRF_Y1 R JOIN USEM_Y1 b 
		ON(R.Worker_ID = b.Worker_ID)
	 WHERE b.EndValidity_DATE = @Ld_High_DATE
	   AND R.Begin_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
	   AND R.County_IDNO = ISNULL(@An_County_IDNO,R.County_IDNO)
  ORDER BY Last_NAME,Suffix_NAME,First_NAME,Middle_NAME;
END; ---End of RWPRF_RETRIEVE_S3

GO
