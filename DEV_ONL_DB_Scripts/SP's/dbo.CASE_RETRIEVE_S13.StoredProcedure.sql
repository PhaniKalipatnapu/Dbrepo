/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S13]  
(

     @An_Case_IDNO                          NUMERIC(6)               ,
     @An_TransactionEventSeq_NUMB                    NUMERIC(19)            OUTPUT,
     @An_Office_IDNO                        NUMERIC(3)               OUTPUT)
AS
/*
  *     PROCEDURE NAME    : CASE_RETRIEVE_S13
  *     DESCRIPTION       : Retrieve Office Code and Transaction sequence for a Case Idno
  *     DEVELOPED BY      : IMP Team   
  *     DEVELOPED ON      : 02-SEP-2011   
  *     MODIFIED BY       :    
  *     MODIFIED ON       :    
  *     VERSION NO        : 1   
*/
   BEGIN
      SET @An_TransactionEventSeq_NUMB = NULL;
      DECLARE
		 @Ld_High_DATE                            DATE = '12/31/9999';
        SELECT  @An_Office_IDNO              = CS.Office_IDNO, 
				@An_TransactionEventSeq_NUMB = CS.TransactionEventSeq_NUMB
      FROM CASE_Y1 CS, OFIC_Y1 O
      WHERE 
         CS.Case_IDNO = @An_Case_IDNO 	 AND 
         CS.Office_IDNO = O.Office_IDNO  AND 
         O.EndValidity_DATE = @Ld_High_DATE;                  
END

GO
