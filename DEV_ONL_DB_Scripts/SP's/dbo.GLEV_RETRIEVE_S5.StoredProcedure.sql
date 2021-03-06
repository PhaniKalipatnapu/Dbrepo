/****** Object:  StoredProcedure [dbo].[GLEV_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 
   
CREATE PROCEDURE [dbo].[GLEV_RETRIEVE_S5](    
 @An_Case_IDNO			  NUMERIC(6),    
 @Ad_EffectiveEvent_DATE  DATE		= NULL,    
 @Ac_GroupFunction_CODE   CHAR(4)	= 'CASE',    
 @Ac_Select_INDC          CHAR(1)	= 'N',    
 @Ax_EventFunctional_XML  XML		= NULL,    
 @Ai_RowFrom_NUMB         INT		= 1,    
 @Ai_RowTo_NUMB           INT		= 10    
 )    
AS    
 /*                                                                                                                                                                                                    
  *     PROCEDURE NAME    : GLEV_RETRIEVE_S5                                                                                                                                                            
  *     DESCRIPTION       : Procedure to retrieves the event master details for a given case and 
                            global event sequence                                                                                                                                                                          
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                 
  *     DEVELOPED ON      : 25/11/2011                                                                                       
  *     MODIFIED BY       :                                                                                                                                                                            
  *     MODIFIED ON       :                                                                                                                                                                            
  *     VERSION NO        : 1                                                                                                                                                                          
  */    
 BEGIN    
  DECLARE @Li_ArrearAdjustment1030_NUMB      INT = 1030,
          @Li_DirectPayCredit1040_NUMB       INT = 1040,
          @Li_IdentifyAReceipt1410_NUMB      INT = 1410,
          @Li_ReceiptOnHold1420_NUMB         INT = 1420,
          @Li_ReleaseAHeldReceipt1430_NUMB   INT = 1430,
          @Li_TanfDistribution1830_NUMB      INT = 1830,
          @Li_ReceiptDistributed1820_NUMB    INT = 1820,
          @Li_RrepReversalRepost1260_NUMB    INT = 1260,
          @Li_ReceiptReversed1250_NUMB       INT = 1250,
          
          @Lc_SelectN_INDC   CHAR(1) = 'N',    
          @Lc_GroupRECI_CODE CHAR(4) = 'RECI',    
          @Lc_TypeCase_TEXT  CHAR(4) = 'CASE',    
          @Lc_GroupDIST_CODE CHAR(4) = 'DIST',    
          @Lc_GroupADJU_CODE CHAR(4) = 'ADJU',    
          @Lc_GroupTANF_CODE CHAR(4) = 'TANF',    
          @Lc_GroupREVR_CODE CHAR(4) = 'REVR',    
          @Ld_High_DATE      DATE    = '12/31/9999';
  DECLARE        
          @Lc_Entity_ID      CHAR(30);    
            
          SET @Lc_Entity_ID = CAST (@An_Case_IDNO AS VARCHAR);   
              
  DECLARE @Lt_EventGroup_P1 AS TABLE (    
   GroupFunction_CODE      CHAR(4),    
   EventFunctionalSeq_NUMB NUMERIC(4));    
    
  INSERT INTO @Lt_EventGroup_P1    
              (GroupFunction_CODE,    
               EventFunctionalSeq_NUMB)    
       VALUES(@Lc_GroupRECI_CODE,    
              @Li_IdentifyAReceipt1410_NUMB );    

  INSERT INTO @Lt_EventGroup_P1    
              (GroupFunction_CODE,    
               EventFunctionalSeq_NUMB)    
       VALUES(@Lc_GroupRECI_CODE,    
              @Li_ReceiptOnHold1420_NUMB );    

  INSERT INTO @Lt_EventGroup_P1    
              (GroupFunction_CODE,    
               EventFunctionalSeq_NUMB)    
       VALUES(@Lc_GroupRECI_CODE,    
              @Li_ReleaseAHeldReceipt1430_NUMB );    
    
  INSERT INTO @Lt_EventGroup_P1    
              (GroupFunction_CODE,    
               EventFunctionalSeq_NUMB)    
       VALUES(@Lc_GroupDIST_CODE,    
              @Li_ReceiptDistributed1820_NUMB );       
    
  INSERT INTO @Lt_EventGroup_P1    
              (GroupFunction_CODE,    
               EventFunctionalSeq_NUMB)    
       VALUES(@Lc_GroupADJU_CODE,    
              @Li_ArrearAdjustment1030_NUMB);
                 
    INSERT INTO @Lt_EventGroup_P1    
              (GroupFunction_CODE,    
               EventFunctionalSeq_NUMB)    
       VALUES(@Lc_GroupADJU_CODE,    
              @Li_DirectPayCredit1040_NUMB );              
    
  INSERT INTO @Lt_EventGroup_P1    
              (GroupFunction_CODE,    
               EventFunctionalSeq_NUMB)    
       VALUES(@Lc_GroupTANF_CODE,    
              @Li_TanfDistribution1830_NUMB );    
    
  INSERT INTO @Lt_EventGroup_P1    
              (GroupFunction_CODE,    
               EventFunctionalSeq_NUMB)    
       VALUES(@Lc_GroupREVR_CODE,    
              @Li_RrepReversalRepost1260_NUMB );   
               
  INSERT INTO @Lt_EventGroup_P1    
              (GroupFunction_CODE,    
               EventFunctionalSeq_NUMB)    
       VALUES(@Lc_GroupREVR_CODE,    
              @Li_ReceiptReversed1250_NUMB );   
    
  DECLARE @Lt_SelectedEvents_P1 AS TABLE(    
   EventFunctionalSeq_NUMB NUMERIC(4));    
    
  INSERT INTO @Lt_SelectedEvents_P1 (EventFunctionalSeq_NUMB)   
  SELECT nref.value('EventFunctionalSeq_NUMB[1]', 'NUMERIC(4)') AS EventFunctionalSeq_NUMB    
    FROM @Ax_EventFunctional_XML.nodes('//Record') R(nref);    
    
  WITH Event_CTE    
       AS (SELECT X.Event_DATE,    
                  X.EventGlobalSeq_NUMB,    
                  X.EventFunctionalSeq_NUMB,    
                  X.Worker_ID,    
                  YEAR(X.EffectiveEvent_DATE) * 100 + MONTH(X.EffectiveEvent_DATE) AS SupportYearMonth_NUMB,    
                  X.EffectiveEvent_DATE,    
                  X.Row_NUMB,    
                  X.RowCount_NUMB    
             FROM (SELECT GL.Event_DTTM AS Event_DATE,    
                          EM.EventGlobalSeq_NUMB,    
                          EM.EventFunctionalSeq_NUMB,    
                          GL.Worker_ID,    
                          GL.EffectiveEvent_DATE,    
                          ROW_NUMBER() OVER( ORDER BY EM.EventGlobalSeq_NUMB DESC) AS Row_NUMB,    
                          COUNT(1) OVER() AS RowCount_NUMB    
                     FROM GLEV_Y1 GL    
                          JOIN ESEM_Y1 EM    
                           ON GL.EventGlobalSeq_NUMB = EM.EventGlobalSeq_NUMB    
                    WHERE EM.Entity_ID = @Lc_Entity_ID    
                      AND EM.TypeEntity_CODE = @Lc_TypeCase_TEXT    
                      AND GL.EffectiveEvent_DATE <= ISNULL(@Ad_EffectiveEvent_DATE, @Ld_High_DATE )    
                      AND EM.EventFunctionalSeq_NUMB IN (SELECT E.EventFunctionalSeq_NUMB    
                                                           FROM EVMA_Y1 E    
                                                          WHERE @Ac_GroupFunction_CODE = @Lc_TypeCase_TEXT    
                                                          UNION    
                                                         SELECT FE.EventFunctionalSeq_NUMB    
                                                           FROM @Lt_EventGroup_P1 FE    
                                                          WHERE FE.GroupFunction_CODE = @Ac_GroupFunction_CODE)    
                      AND (@Ac_Select_INDC = @Lc_SelectN_INDC    
                            OR EM.EventFunctionalSeq_NUMB IN (SELECT SE.EventFunctionalSeq_NUMB    
                                                                FROM @Lt_SelectedEvents_P1 SE)))  X    
            WHERE X.Row_NUMB BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB)    
  SELECT EV.Event_DATE,    
         EV.EffectiveEvent_DATE,    
         EV.EventFunctionalSeq_NUMB,    
         EVM.DescriptionEvent_TEXT,    
         dbo.BATCH_COMMON$SF_ELOG_KEY(@Lc_Entity_ID, EV.EventFunctionalSeq_NUMB, EV.EventGlobalSeq_NUMB) AS KeyField_TEXT,    
         dbo.BATCH_COMMON$SF_SUM_TXN_AMOUNT(@Lc_Entity_ID, EV.SupportYearMonth_NUMB, EV.EventFunctionalSeq_NUMB, EV.Worker_ID, EV.EffectiveEvent_DATE, EV.EventGlobalSeq_NUMB) AS Transaction_AMNT,    
         dbo.BATCH_COMMON$SF_SUM_LSUP_ARREARS(@Lc_Entity_ID, EV.EffectiveEvent_DATE, EV.EventFunctionalSeq_NUMB, EV.EventGlobalSeq_NUMB, EV.Worker_ID) AS Arrear_AMNT,    
         EV.EventGlobalSeq_NUMB,    
         EV.Worker_ID,    
         EV.RowCount_NUMB    
    FROM Event_CTE EV    
         JOIN EVMA_Y1 EVM    
          ON EV.EventFunctionalSeq_NUMB = EVM.EventFunctionalSeq_NUMB    
   ORDER BY EV.Row_NUMB;    
 END; --End Of Procedure GLEV_RETRIEVE_S5     
    

GO
