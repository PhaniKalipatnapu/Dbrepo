/****** Object:  StoredProcedure [dbo].[ALSP_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ALSP_RETRIEVE_S1](
 @An_Application_IDNO NUMERIC(15),
 @An_MemberMci_IDNO   NUMERIC(10),
 @An_Year_NUMB        NUMERIC(4),
 @An_YearMonth_NUMB   NUMERIC(6)
 )
AS
 /*  
  *     PROCEDURE NAME    : ALSP_RETRIEVE_S1    
  *     DESCRIPTION       : Retrieves the affidavit of payments details  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-NOV-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT AL.YearMonth_NUMB,
         AL.Owed_AMNT,
         AL.Paid_AMNT,
         (AL.Owed_AMNT - AL.Paid_AMNT) AS Balance_NUMB,
         SUM(AL.Owed_AMNT) OVER() AmountOwedTotal_AMNT,
         SUM(AL.Paid_AMNT) OVER() AmountPaidTotal_AMNT,
         SUM(AL.Owed_AMNT - AL.Paid_AMNT) OVER() BalanceTotal_AMNT
    FROM ALSP_Y1 AL
   WHERE AL.Application_IDNO = @An_Application_IDNO
     AND AL.MemberMCI_IDNO = @An_MemberMci_IDNO
     AND CAST(AL.YearMonth_NUMB / 100 AS INT) = ISNULL(@An_Year_NUMB, CAST(AL.YearMonth_NUMB / 100 AS INT))
     AND AL.YearMonth_NUMB = ISNULL(@An_YearMonth_NUMB, AL.YearMonth_NUMB)
   ORDER BY YearMonth_NUMB;
 END; --End of ALSP_RETRIEVE_S1

GO
