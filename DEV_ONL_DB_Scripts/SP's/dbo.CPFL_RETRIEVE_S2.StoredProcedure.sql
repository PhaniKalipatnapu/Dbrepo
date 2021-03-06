/****** Object:  StoredProcedure [dbo].[CPFL_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CPFL_RETRIEVE_S2] (

 @Ad_Batch_DATE        DATE,
 @Ac_SourceBatch_CODE  CHAR(3),
 @An_Batch_NUMB        NUMERIC(4,0),
 @An_SeqReceipt_NUMB   NUMERIC(6,0)
           
 )
AS
/*
 *     PROCEDURE NAME    : CPFL_RETRIEVE_S2
 *     DESCRIPTION       : Retrieveing the cp fees details for the Fee Tab.
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 10-AUG-2011 
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

DECLARE 
        @Lc_TransactionAsmt_CODE CHAR(4) ='ASMT',
        @Lc_TransactionRdca_CODE CHAR(4) ='RDCA',
        @Lc_TransactionSrec_CODE CHAR(4) ='SREC',
        @Lc_TransactionRdcr_CODE CHAR(4) ='RDCR',
        @Li_Zero_NUMB            INT =0;                



SELECT DISTINCT A.Case_IDNO,
		     A.AssessedYear_NUMB,
		     A.FeeType_CODE,
		     SUM(ISNULL(Assessed_AMNT,0)) OVER(PARTITION BY Case_IDNO, AssessedYear_NUMB, FeeType_CODE) AS Assessed_AMNT,
		     SUM(ISNULL(Paid_AMNT,0)) OVER(PARTITION BY Case_IDNO, AssessedYear_NUMB, FeeType_CODE) AS Paid_AMNT,
		     @Li_Zero_NUMB AS Waived_AMNT		     
		   
	FROM (SELECT C.Case_IDNO,
		         C.AssessedYear_NUMB,
		         C.FeeType_CODE,
		         C.MemberMci_IDNO,
		         CASE  WHEN C.Transaction_CODE IN(@Lc_TransactionAsmt_CODE,@Lc_TransactionRdca_CODE) THEN C.Transaction_AMNT 
		         END AS Assessed_AMNT,
		         CASE WHEN C.Transaction_CODE IN(@Lc_TransactionSrec_CODE,@Lc_TransactionRdcr_CODE)  THEN C.Transaction_AMNT 
		         END AS Paid_AMNT,
		         C.EventGlobalSeq_NUMB
		        
		FROM CPFL_Y1 C
		WHERE
			C.Batch_DATE=@Ad_Batch_DATE
			AND C.SourceBatch_CODE=@Ac_SourceBatch_CODE
			AND C.BATCH_NUMB=@An_Batch_NUMB
			AND C.SeqReceipt_NUMB=@An_SeqReceipt_NUMB
	  ) A ;
	 
   
      
END;--End Of CPFL_RETRIEVE_S2


GO
