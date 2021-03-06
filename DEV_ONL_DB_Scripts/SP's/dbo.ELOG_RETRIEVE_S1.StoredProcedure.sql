/****** Object:  StoredProcedure [dbo].[ELOG_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[ELOG_RETRIEVE_S1]  
AS  
 /*                                                                                                                                                                                                         
  *     PROCEDURE NAME    : ELOG_RETRIEVE_S1                                                                                                                                                                
  *     DESCRIPTION       : Procedure To Retrieves the financial events log tree details 
  *     DEVELOPED BY      : IMP TEAM                                                                                                                                                                    
  *     DEVELOPED ON      : 11/23/2011                                                                                                                                                                   
  *     MODIFIED BY       :                                                                                                                                                                                 
  *     MODIFIED ON       :                                                                                                                                                                                 
  *     VERSION NO        : 1                                                                                                                                                                               
 */  
 BEGIN  
   
     DECLARE
    @Lc_GroupFunctionFin_CODE   CHAR(3) = 'FIN',
    @Lc_GroupFunctionFin1_CODE  CHAR(11)= 'FINANCIALS';
   
  WITH ETree_CTE  
       AS (SELECT EL.NodeTreeDepth_NUMB,  
                  EL.GroupFunction_NAME,  
                  EL.EventFunctionalSeq_NUMB,  
                  EL.DescriptionEvent_TEXT,  
                  EL.InitialState_CODE AS InitialState_CODE,  
                  1 AS LEVEL,  
				  EL.EventFunctionalSeq_NUMB AS EventFunctionalSeqOrder_NUMB         
             FROM ELOG_Y1 EL  
            WHERE EL.GroupFunction_NAME IN(@Lc_GroupFunctionFin_CODE)  
            UNION ALL  
           SELECT EL.NodeTreeDepth_NUMB,  
                  EL.GroupFunction_NAME,  
                  EL.EventFunctionalSeq_NUMB,  
                  EL.DescriptionEvent_TEXT,  
                  EL.InitialState_CODE AS InitialState_CODE,  
                  ET.LEVEL + 1 AS LEVEL,  
                  EL.EventFunctionalSeq_NUMB AS EventFunctionalSeqOrder_NUMB  
             FROM ELOG_Y1 EL  
                  JOIN ETree_CTE ET  
                   ON EL.GroupFunction_NAME     = ET.DescriptionEvent_TEXT  
                      AND EL.GroupFunction_NAME IN(@Lc_GroupFunctionFin1_CODE)  
            UNION ALL  
           SELECT EL.NodeTreeDepth_NUMB,  
                  EL.GroupFunction_NAME,  
                  EL.EventFunctionalSeq_NUMB,  
                  EL.DescriptionEvent_TEXT,  
                  EL.InitialState_CODE AS InitialState_CODE,  
                  ET.LEVEL ,  
                  ET.EventFunctionalSeq_NUMB AS EventFunctionalSeqOrder_NUMB  
             FROM ELOG_Y1 EL  
                  JOIN ETree_CTE ET  
                   ON EL.GroupFunction_NAME = ET.DescriptionEvent_TEXT  
                       AND EL.GroupFunction_NAME NOT IN(@Lc_GroupFunctionFin_CODE)  
                       AND ET.GroupFunction_NAME NOT IN(@Lc_GroupFunctionFin_CODE))  
                    
  SELECT EL.NodeTreeDepth_NUMB,  
         EL.EventFunctionalSeq_NUMB,  
         EL.DescriptionEvent_TEXT,  
         EL.InitialState_CODE 
    FROM ETree_CTE EL  
   ORDER BY EL.EventFunctionalSeqOrder_NUMB, EL.InitialState_CODE;  
   
 END; --End Of Procedure ELOG_RETRIEVE_S1 


GO
