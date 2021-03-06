/****** Object:  StoredProcedure [dbo].[BSAXT_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAXT_RETRIEVE_S7] (
	@Ac_TypeComponent_CODE			CHAR(4),
	@Ad_ReviewFrom_DATE				DATE			OUTPUT,
	@Ad_ReviewTo_DATE				DATE			OUTPUT,
	@An_SampleSize_QNTY				NUMERIC(7,0)	OUTPUT,
	@Ac_WorkerUpdate_ID				CHAR(30)		OUTPUT,
	@Ad_Request_DATE				DATE			OUTPUT,
	@As_Component_NAME				VARCHAR(50)		OUTPUT
)
AS
/*
 *     PROCEDURE NAME    : BSAXT_RETRIEVE_S7
 *     DESCRIPTION       : This procedure is used to Retrieves self assessment header details.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 16-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
	 SELECT @Ad_ReviewFrom_DATE		= NULL,
			@Ad_ReviewTo_DATE		= NULL,	
			@An_SampleSize_QNTY		= NULL,
			@Ac_WorkerUpdate_ID		= NULL,
			@Ad_Request_DATE		= NULL,
			@As_Component_NAME		= NULL;
				
    DECLARE @Ld_High_DATE		DATE = '12/31/9999';

	 SELECT @As_Component_NAME		= a.Component_NAME,
			@Ad_ReviewFrom_DATE		= a.ReviewFrom_DATE,
			@Ad_ReviewTo_DATE		= a.ReviewTo_DATE,
			@An_SampleSize_QNTY		= a.SampleSize_QNTY,
			@Ad_Request_DATE		= a.Request_DATE,
			@Ac_WorkerUpdate_ID		= a.WorkerUpdate_ID			
	   FROM BSAXT_Y1  a
	  WHERE a.TypeComponent_CODE = @Ac_TypeComponent_CODE
	    AND a.EndValidity_DATE	 = @Ld_High_DATE;	
	   
END  -- END OF BSAXT_RETRIEVE_S7


GO
