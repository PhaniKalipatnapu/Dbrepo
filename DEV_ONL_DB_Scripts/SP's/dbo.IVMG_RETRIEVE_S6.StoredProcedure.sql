/****** Object:  StoredProcedure [dbo].[IVMG_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IVMG_RETRIEVE_S6] (
 @An_CpMci_IDNO            NUMERIC(10, 0),
 @An_CaseWelfare_IDNO      NUMERIC(10, 0),
 @Ac_WelfareElig_CODE      CHAR(1),
 @An_WelfareYearMonth_NUMB NUMERIC(6, 0),
 @An_MtdAssistExpend_AMNT  NUMERIC(11, 2) OUTPUT,
 @An_LtdAssistExpend_AMNT  NUMERIC(11, 2) OUTPUT,
 @An_MtdAssistRecoup_AMNT  NUMERIC(11, 2) OUTPUT,
 @An_LtdAssistRecoup_AMNT  NUMERIC(11, 2) OUTPUT,
 @An_Defra_AMNT            NUMERIC(11, 2) OUTPUT,
 @An_EventGlobalSeq_NUMB   NUMERIC(19, 0) OUTPUT,
 @Ad_Event_DTTM            DATETIME2 OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : IVMG_RETRIEVE_S6
  *     DESCRIPTION       : Retrieves the monthly grant details for the given welfare id and month year.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_MtdAssistExpend_AMNT = NULL;
  SET @An_LtdAssistExpend_AMNT = NULL;
  SET @An_MtdAssistRecoup_AMNT = NULL;
  SET @An_LtdAssistRecoup_AMNT = NULL;
  SET @An_Defra_AMNT = NULL;
  SET @An_EventGlobalSeq_NUMB = NULL;
  SET @Ad_Event_DTTM = NULL;

  SELECT @An_MtdAssistExpend_AMNT = I.MtdAssistExpend_AMNT,
         @An_LtdAssistExpend_AMNT = I.LtdAssistExpend_AMNT,
         @An_MtdAssistRecoup_AMNT = I.MtdAssistRecoup_AMNT,
         @An_LtdAssistRecoup_AMNT = I.LtdAssistRecoup_AMNT,
         @An_Defra_AMNT = I.Defra_AMNT,
         @An_EventGlobalSeq_NUMB = I.EventGlobalSeq_NUMB,
         @Ad_Event_DTTM = CONVERT(DATE, G.Event_DTTM)
    FROM IVMG_Y1 I,
         GLEV_Y1 G
   WHERE I.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
     AND I.WelfareElig_CODE = @Ac_WelfareElig_CODE
     AND I.WelfareYearMonth_NUMB = @An_WelfareYearMonth_NUMB
     AND I.CpMci_IDNO = ISNULL(@An_CpMci_IDNO, I.CpMci_IDNO)
     AND I.EventGlobalSeq_NUMB = (SELECT MAX(A.EventGlobalSeq_NUMB) AS expr
                                    FROM IVMG_Y1 A
                                   WHERE A.CaseWelfare_IDNO = I.CaseWelfare_IDNO
                                     AND A.WelfareElig_CODE = I.WelfareElig_CODE
                                     AND A.WelfareYearMonth_NUMB = I.WelfareYearMonth_NUMB)
     AND G.EventGlobalSeq_NUMB = I.EventGlobalSeq_NUMB;
 END; -- End of IVMG_RETRIEVE_S6

GO
