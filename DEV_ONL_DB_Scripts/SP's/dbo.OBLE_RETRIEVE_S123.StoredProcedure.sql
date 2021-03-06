/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S123]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S123](
 @An_Case_IDNO NUMERIC(6,0)
 )
AS
 /*                                                                                                                                                                                                                                                                                                                                                                                                             
  *     PROCEDURE NAME    : OBLE_RETRIEVE_S123                                                                                                                                                                                                                                                                                                                                                                   
  *     DESCRIPTION       : This procedure used to display obligation for the case                                                                                                                                                                                                                                                                                                                                                                                   
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                                                                                                                                                                                                          
  *     DEVELOPED ON      : 12/10/2011                                                                                                                                                                                                                                                                                                                                                                        
  *     MODIFIED BY       :                                                                                                                                                                                                                                                                                                                                                                                     
  *     MODIFIED ON       :                                                                                                                                                                                                                                                                                                                                                                                     
  *     VERSION NO        : 1                                                                                                                                                                                                                                                                                                                                                                                   
  */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT OB.TypeDebt_CODE,
         OB.MemberMci_IDNO,
         OB.Fips_CODE,
         OB.OrderSeq_NUMB,
         OB.ObligationSeq_NUMB
    FROM OBLE_Y1 OB
   WHERE OB.Case_IDNO = @An_Case_IDNO
     AND OB.EndValidity_DATE = @Ld_High_DATE
   ORDER BY OB.ObligationSeq_NUMB DESC;
   
 END; --End Of Procedure OBLE_RETRIEVE_S123 


GO
