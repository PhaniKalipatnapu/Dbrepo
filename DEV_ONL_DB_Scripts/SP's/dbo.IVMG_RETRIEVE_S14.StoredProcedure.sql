/****** Object:  StoredProcedure [dbo].[IVMG_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IVMG_RETRIEVE_S14] (
 @An_CaseWelfare_IDNO				NUMERIC(10),
 @An_WelfareYearMonth_NUMB			NUMERIC(6),
 @Ac_WelfareElig_CODE				CHAR(1),
 @An_MtdAssistExpend_AMNT			NUMERIC(11, 2) OUTPUT,
 @An_LtdAssistExpend_AMNT			NUMERIC(11, 2) OUTPUT,
 @An_MtdAssistRecoup_AMNT			NUMERIC(11, 2) OUTPUT,
 @An_LtdAssistRecoup_AMNT			NUMERIC(11, 2) OUTPUT,
 @Ac_TypeAdjust_CODE				CHAR(1) OUTPUT,
 @Ac_ZeroGrant_INDC					CHAR(1) OUTPUT,
 @Ac_AdjustLtdFlag_INDC				CHAR(1) OUTPUT,
 @An_Defra_AMNT						NUMERIC(11, 2) OUTPUT,
 @An_TransactionAssistExpend_AMNT	NUMERIC(11, 2) OUTPUT,
 @An_TransactionAssistRecoup_AMNT	NUMERIC(11, 2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : IVMG_RETRIEVE_S14
  *     DESCRIPTION       : Retrieves the monthly grant details for the given welfare id and month year.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  
  --13606 - IVMG - CR0401 Allow URA Record to be Added to IVMG 20140814 - START -

  SELECT @An_MtdAssistExpend_AMNT = A.MtdAssistExpend_AMNT,
         @An_LtdAssistExpend_AMNT = A.LtdAssistExpend_AMNT,
         @An_MtdAssistRecoup_AMNT = A.MtdAssistRecoup_AMNT,
         @An_LtdAssistRecoup_AMNT = A.LtdAssistRecoup_AMNT,
         @Ac_TypeAdjust_CODE = A.TypeAdjust_CODE,
         @Ac_ZeroGrant_INDC = A.ZeroGrant_INDC,
         @Ac_AdjustLtdFlag_INDC = A.AdjustLtdFlag_INDC,
         @An_Defra_AMNT = A.Defra_AMNT,
         @An_TransactionAssistExpend_AMNT = TransactionAssistExpend_AMNT,
         @An_TransactionAssistRecoup_AMNT = TransactionAssistRecoup_AMNT
    FROM IVMG_Y1 A
   WHERE A.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
     AND A.WelfareElig_CODE = @Ac_WelfareElig_CODE
     AND A.WelfareYearMonth_NUMB = (SELECT MAX (C.WelfareYearMonth_NUMB) AS expr
                                      FROM IVMG_Y1 C
                                     WHERE C.CaseWelfare_IDNO = A.CaseWelfare_IDNO
                                       AND C.WelfareYearMonth_NUMB <= @An_WelfareYearMonth_NUMB
                                       AND C.WelfareElig_CODE = A.WelfareElig_CODE)
     AND A.EventGlobalSeq_NUMB = (SELECT MAX (B.EventGlobalSeq_NUMB) AS expr
                                    FROM IVMG_Y1 B
                                   WHERE B.CaseWelfare_IDNO = A.CaseWelfare_IDNO
                                     AND B.WelfareYearMonth_NUMB = A.WelfareYearMonth_NUMB
                                     AND B.WelfareElig_CODE = A.WelfareElig_CODE);
 END; -- End of IVMG_RETRIEVE_S14;
 --13606 - IVMG - CR0401 Allow URA Record to be Added to IVMG 20140814 - END -

GO
