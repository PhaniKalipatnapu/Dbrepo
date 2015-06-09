/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S165]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S165]
(
	@An_Case_IDNO				NUMERIC(6,0),
	@Ad_NonWageReceipt_DATE 	DATE OUTPUT
)
AS
/*                                                                                     
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S165                                            
  *     DESCRIPTION       : This procedure is used to retrieve the receipt date for non employer wage.
  *     DEVELOPED BY      : IMP TEAM                                                
  *     DEVELOPED ON      : 03/13/2012  
  *     MODIFIED BY       :                                                             
  *     MODIFIED ON       :                                                             
  *     VERSION NO        : 1                                                           
  */
BEGIN 
		SET @Ad_NonWageReceipt_DATE 			= NULL;
 
	DECLARE @Lc_CaseMemberStatusA_CODE		CHAR(1) = 'A',
			@Lc_StatusReceiptD_CODE			CHAR(1) = 'D',
			@Lc_StatusReceiptP_CODE			CHAR(1) = 'P',
			@Lc_SourceReceiptEW_CODE		CHAR(2) = 'EW';
 
	SELECT @Ad_NonWageReceipt_DATE  = r.Receipt_DATE
	  FROM RCTH_Y1 r JOIN CMEM_Y1 c
		ON r.Case_IDNO = c.Case_IDNO
	 WHERE c.Case_IDNO = @An_Case_IDNO
	   AND r.SourceReceipt_CODE <> @Lc_SourceReceiptEW_CODE
	   AND r.StatusReceipt_CODE IN (@Lc_StatusReceiptD_CODE, @Lc_StatusReceiptP_CODE)
	   AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE;
 
END --End Of Procedure RCTH_RETRIEVE_S165
 

GO
