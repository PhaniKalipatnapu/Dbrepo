/****** Object:  StoredProcedure [dbo].[IVMG_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IVMG_INSERT_S1](
 @An_CaseWelfare_IDNO             NUMERIC(10, 0),
 @An_WelfareYearMonth_NUMB        NUMERIC(6, 0),
 @Ac_WelfareElig_CODE             CHAR(1),
 @An_TransactionAssistExpend_AMNT NUMERIC(11, 2),
 @An_MtdAssistExpend_AMNT         NUMERIC(11, 2),
 @An_LtdAssistExpend_AMNT         NUMERIC(11, 2),
 @An_TransactionAssistRecoup_AMNT NUMERIC(11, 2),
 @An_MtdAssistRecoup_AMNT         NUMERIC(11, 2),
 @An_LtdAssistRecoup_AMNT         NUMERIC(11, 2),
 @Ac_TypeAdjust_CODE              CHAR(1),
 @An_EventGlobalSeq_NUMB		  NUMERIC(19, 0),
 @Ac_ZeroGrant_INDC               CHAR(1),
 @Ac_AdjustLtdFlag_INDC           CHAR(1),
 @An_Defra_AMNT                   NUMERIC(11, 2),
 @An_CpMci_IDNO					  NUMERIC(10, 0)
 )
AS
 /*                                                                                                                                                                        
  *     PROCEDURE NAME    : IVMG_INSERT_S1                                                                                                                                 
  *     DESCRIPTION       : Inserts the Monthly grant modification details.
  *     DEVELOPED BY      : IMP Team                                                                                                                                     
  *     DEVELOPED ON      : 02-NOV-2011                                                                                                                                    
  *     MODIFIED BY       :                                                                                                                                                
  *     MODIFIED ON       :                                                                                                                                                
  *     VERSION NO        : 1                                                                                                                                              
 */
 BEGIN
  INSERT IVMG_Y1
         (CaseWelfare_IDNO,
          WelfareYearMonth_NUMB,
          WelfareElig_CODE,
          TransactionAssistExpend_AMNT,
          MtdAssistExpend_AMNT,
          LtdAssistExpend_AMNT,
          TransactionAssistRecoup_AMNT,
          MtdAssistRecoup_AMNT,
          LtdAssistRecoup_AMNT,
          TypeAdjust_CODE,
          EventGlobalSeq_NUMB,
          ZeroGrant_INDC,
          AdjustLtdFlag_INDC,
          Defra_AMNT,
		  CpMci_IDNO)
  VALUES( @An_CaseWelfare_IDNO,
          @An_WelfareYearMonth_NUMB,
          @Ac_WelfareElig_CODE,
          @An_TransactionAssistExpend_AMNT,
          @An_MtdAssistExpend_AMNT,
          @An_LtdAssistExpend_AMNT,
          @An_TransactionAssistRecoup_AMNT,
          @An_MtdAssistRecoup_AMNT,
          @An_LtdAssistRecoup_AMNT,
          @Ac_TypeAdjust_CODE,
          @An_EventGlobalSeq_NUMB,
          @Ac_ZeroGrant_INDC,
          @Ac_AdjustLtdFlag_INDC,
          @An_Defra_AMNT,
		  @An_CpMci_IDNO);
 END; --End of IVMG_INSERT_S1



GO
