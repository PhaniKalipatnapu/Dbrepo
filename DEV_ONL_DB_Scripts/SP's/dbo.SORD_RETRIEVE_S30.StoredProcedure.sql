/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S30]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S30] (
     @An_Case_IDNO			 NUMERIC(6,0),
     @An_OrderSeq_NUMB		 NUMERIC(2,0),
     @Ac_File_ID			 CHAR(10)               
	)
AS
		
/*
 *     PROCEDURE NAME    : SORD_RETRIEVE_S30
 *     DESCRIPTION       : This procedure returns the order information that to be display in order details grid.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 20-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN   
     DECLARE @Li_Zero_NUMB					SMALLINT= 0,
			 @Lc_CaseLevel_CODE				CHAR(1) = 'C',  
			 @Ld_High_DATE					DATE	= '12/31/9999';        
    
      SELECT a.Case_IDNO, 
			 a.File_ID  , 
			 a.SourceOrdered_CODE , 
			 a.TypeOrder_CODE , 
			 a.OrderEffective_DATE , 
			 a.OrderEnd_DATE,				   
			 a.OrderIssued_DATE , 
			 DBO.BATCH_COMMON$SF_GET_PAYBACK_AMNT(a.Case_IDNO,a.OrderSeq_NUMB) AS Payback_AMNT, 
			 DBO.BATCH_COMMON$SF_GET_OBLEARREARS(a.Case_IDNO,a.OrderSeq_NUMB,@Li_Zero_NUMB,NULL,@Lc_CaseLevel_CODE,NULL) AS TotalBal_AMNT, 
			 a.OrderSeq_NUMB
        FROM SORD_Y1  a
       WHERE a.Case_IDNO		= ISNULL(@An_Case_IDNO,a.Case_IDNO)
         AND a.OrderSeq_NUMB	= ISNULL(@An_OrderSeq_NUMB,a.OrderSeq_NUMB)
         AND a.File_ID			= ISNULL(@Ac_File_ID,a.File_ID)
         AND a.EndValidity_DATE = @Ld_High_DATE
      ORDER BY Case_IDNO ASC;

END;--End of SORD_RETRIEVE_S30


GO
