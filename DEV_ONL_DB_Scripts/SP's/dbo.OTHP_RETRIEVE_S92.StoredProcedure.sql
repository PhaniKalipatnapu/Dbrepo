/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S92]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S92] (
 @An_OtherParty_IDNO          NUMERIC(9, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_TypeOthp_CODE            CHAR(1) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S92  
  *     DESCRIPTION       : Retrieve an Other Party TYPE for an Other Party number. 
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 11-AUG-2011
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SET @Ac_TypeOthp_CODE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_TypeOthp_CODE = O.TypeOthp_CODE
    FROM OTHP_Y1 O
   WHERE O.OtherParty_IDNO = @An_OtherParty_IDNO
     AND O.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND O.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF OTHP_RETRIEVE_S92



GO
