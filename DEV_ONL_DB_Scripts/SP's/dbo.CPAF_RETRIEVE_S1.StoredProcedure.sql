/****** Object:  StoredProcedure [dbo].[CPAF_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CPAF_RETRIEVE_S1] ( 
 @An_Case_IDNO		          NUMERIC(6,0),
 @An_TransactionEventSeq_NUMB NUMERIC(19,0),
 @Ac_Exists_INDC              CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CPAF_RETRIEVE_S1
  *     DESCRIPTION       : Check whether the valid record is exist for the given case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  
  DECLARE @Lc_No_TEXT	CHAR(1) = 'N',
		  @Lc_Yes_TEXT	CHAR(1) = 'Y',
		  @Ld_High_DATE DATE = '12/31/9999';

  SET @Ac_Exists_INDC = @Lc_No_TEXT;

  SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM CPAF_Y1 C
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND C.TransactionEventSeq_NUMB = ISNULL(@An_TransactionEventSeq_NUMB, C.TransactionEventSeq_NUMB)
     AND C.EndValidity_DATE = @Ld_High_DATE;
				   
 END; --End of CPAF_RETRIEVE_S1
 

GO
