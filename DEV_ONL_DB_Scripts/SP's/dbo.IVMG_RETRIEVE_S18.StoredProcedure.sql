/****** Object:  StoredProcedure [dbo].[IVMG_RETRIEVE_S18]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IVMG_RETRIEVE_S18](
	 @An_CaseWelfare_IDNO    NUMERIC(10),
	 @An_EventGlobalSeq_NUMB NUMERIC(19)
 )
AS
 /*
  *     PROCEDURE NAME    : IVMG_RETRIEVE_S18
  *     DESCRIPTION       : This pop-up displays the details of the IV-A grant, life to date expended and
							reimbursed and the life to date un-reimbursed amounts.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12/10/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT i.ZeroGrant_INDC,
         i.WelfareYearMonth_NUMB,
         i.MtdAssistExpend_AMNT,
         i.LtdAssistExpend_AMNT,
         i.LtdAssistRecoup_AMNT,
         (i.LtdAssistExpend_AMNT - i.LtdAssistRecoup_AMNT) AS Ura_AMNT,
         UN.DescriptionNote_TEXT
    FROM IVMG_Y1 i
         LEFT OUTER JOIN UNOT_Y1 UN
      ON i.EventGlobalSeq_NUMB = UN.EventGlobalSeq_NUMB
   WHERE i.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
     AND i.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
   ORDER BY i.WelfareYearMonth_NUMB DESC;
   
 END; --End Of Procedure IVMG_RETRIEVE_S18 


GO
