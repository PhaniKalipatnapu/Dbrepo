/****** Object:  StoredProcedure [dbo].[FSRT_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE 
	[dbo].[FSRT_RETRIEVE_S5]
		(
		  @An_Case_IDNO 				NUMERIC(6,0),
		  @An_Petition_IDNO				NUMERIC(7,0),
		  @An_MajorIntSeq_NUMB			NUMERIC(5,0),
		  @An_MinorIntSeq_NUMB			NUMERIC(5,0),
		  @An_TransactionEventSeq_NUMB	NUMERIC(19,0), 
		  @Ac_File_ID 					CHAR(10),
		  @Ac_Exists_INDC				CHAR(1)		OUTPUT
		)
AS

/*                                                                                                                                    
 *     PROCEDURE NAME    : FSRT_RETRIEVE_S5                                                                                           
 *     DESCRIPTION       : Check the record existance for concurrency check 
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 25-JAN-2012                                                                                               
 *     MODIFIED BY       :                                                                                                            
 *     MODIFIED ON       :                                                                                                            
 *     VERSION NO        : 1                                                                                                          
*/ 

BEGIN

  DECLARE 
	@Lc_Yes_INDC	CHAR(1) = 'Y' ,
    @Lc_No_INDC		CHAR(1) = 'N',
	@Ld_High_DATE   DATE	= '12/31/9999';
	
 SET 
	@Ac_Exists_INDC = @Lc_No_INDC ;

  SELECT @Ac_Exists_INDC= @Lc_Yes_INDC
    FROM FSRT_Y1 f
   WHERE f.Case_IDNO = @An_Case_IDNO 
     AND f.File_ID = @Ac_File_ID
     AND f.Petition_IDNO = @An_Petition_IDNO
     AND f.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
     AND f.MinorIntSEQ_NUMB = @An_MinorIntSeq_NUMB
     AND f.TransactionEventSeq_NUMB=@An_TransactionEventSeq_NUMB
     AND f.EndValidity_DATE = @Ld_High_DATE;

END;	--END OF FSRT_RETRIEVE_S5


GO
