/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S9]  
 (
     @An_Case_IDNO		 NUMERIC(6,0),
     @An_OrderSeq_NUMB	 NUMERIC(2,0)
  )              
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S9
 *     DESCRIPTION       :  Procedure to populate the obligation dropdown field in the filter.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN

       DECLARE @Ld_High_DATE DATE = '12/31/9999';
        
        SELECT DISTINCT A.ObligationSeq_NUMB,
					    A.MemberMci_IDNO,
					    A.Fips_CODE,
					    A.TypeDebt_CODE 
          FROM OBLE_Y1 A
         WHERE A.Case_IDNO = @An_Case_IDNO 
           AND A.OrderSeq_NUMB = @An_OrderSeq_NUMB 
           AND A.EndValidity_DATE = @Ld_High_DATE
      ORDER BY TypeDebt_CODE;

END;--End of OBLE_RETRIEVE_S9


GO
