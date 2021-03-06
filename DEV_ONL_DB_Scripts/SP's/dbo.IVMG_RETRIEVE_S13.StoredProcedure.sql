/****** Object:  StoredProcedure [dbo].[IVMG_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IVMG_RETRIEVE_S13] (
 @An_CaseWelfare_IDNO      NUMERIC(10, 0),
 @Ac_WelfareElig_CODE      CHAR(1),
 @An_WelfareYearMonth_NUMB NUMERIC(6, 0),
 @An_MtdAssistExpend_AMNT  NUMERIC(11, 2) OUTPUT,
 @An_LtdAssistExpend_AMNT  NUMERIC(11, 2) OUTPUT,
 @An_MtdAssistRecoup_AMNT  NUMERIC(11, 2) OUTPUT,
 @An_LtdAssistRecoup_AMNT  NUMERIC(11, 2) OUTPUT,
 @Ac_TypeAdjust_CODE       CHAR(1) OUTPUT,
 @An_EventGlobalSeq_NUMB   NUMERIC(19, 0) OUTPUT,
 @Ac_ZeroGrant_INDC        CHAR(1) OUTPUT,
 @Ac_AdjustLtdFlag_INDC    CHAR(1) OUTPUT,
 @An_Defra_AMNT            NUMERIC(11, 2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : IVMG_RETRIEVE_S13
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
  SET @Ac_TypeAdjust_CODE = NULL;
  SET @An_EventGlobalSeq_NUMB = NULL;
  SET @Ac_ZeroGrant_INDC = NULL;
  SET @Ac_AdjustLtdFlag_INDC = NULL;
  SET @An_Defra_AMNT = NULL;

  SELECT @An_MtdAssistExpend_AMNT = A.MtdAssistExpend_AMNT,
         @An_LtdAssistExpend_AMNT = A.LtdAssistExpend_AMNT,
         @An_MtdAssistRecoup_AMNT = A.MtdAssistRecoup_AMNT,
         @An_LtdAssistRecoup_AMNT = A.LtdAssistRecoup_AMNT,
         @Ac_TypeAdjust_CODE = A.TypeAdjust_CODE,
		 @An_EventGlobalSeq_NUMB = A.EventGlobalSeq_NUMB,
         @Ac_ZeroGrant_INDC = A.ZeroGrant_INDC,
         @Ac_AdjustLtdFlag_INDC = A.AdjustLtdFlag_INDC,
         @An_Defra_AMNT = A.Defra_AMNT
    FROM (SELECT A.MtdAssistExpend_AMNT,
				A.LtdAssistExpend_AMNT,
				A.MtdAssistRecoup_AMNT,
				A.LtdAssistRecoup_AMNT,
				A.TypeAdjust_CODE,
				A.EventGlobalSeq_NUMB,
				A.ZeroGrant_INDC,
				A.AdjustLtdFlag_INDC,
				A.Defra_AMNT,
               ROW_NUMBER() OVER(PARTITION BY CaseWelfare_IDNO, A.WelfareElig_CODE ORDER BY A.WelfareYearMonth_NUMB DESC,
               A.EventGlobalSeq_NUMB DESC) RNM
          FROM IVMG_Y1 A
         WHERE A.CaseWelfare_IDNO=@An_CaseWelfare_IDNO
           AND A.WelfareElig_CODE=@Ac_WelfareElig_CODE
           AND A.WelfareYearMonth_NUMB=ISNULL(@An_WelfareYearMonth_NUMB, A.WelfareYearMonth_NUMB)) A
WHERE RNM=1; 

 END; -- End of IVMG_RETRIEVE_S13


GO
