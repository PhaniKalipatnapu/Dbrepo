/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S78]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S78] (    
 @An_County_IDNO       NUMERIC(3, 0),    
 @As_OtherParty_NAME   VARCHAR(60),    
 @Ac_TypeActivity_CODE CHAR(1),    
 @Ai_RowFrom_NUMB      INT = 1,    
 @Ai_RowTo_NUMB        INT = 10    
 )    
AS    
 /*    
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S78    
  *     DESCRIPTION       : Retrieve Other Party details for an Other Party number,Type and State Address.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 06-SEP-2011        
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */    
 BEGIN    
  DECLARE    
          @Lc_ActivityTypeHearing_CODE      CHAR(1) = 'H',    
          @Lc_SchLocTypeCourt_CODE          CHAR(1) = 'C',    
          @Lc_SchLocTypeLab_CODE            CHAR(1) = 'L',    
          @Lc_SchLocTypeOffice_CODE         CHAR(1) = 'O',    
          @Lc_AddrState_TEXT                CHAR(2) = 'DE',      
          @Li_Zero_NUMB                     SMALLINT = 0,      
          @Lc_Empty_TEXT                    CHAR(2) = '';    
              
    
  SELECT T.OtherParty_IDNO,    
         T.OtherParty_NAME,    
         T.City_ADDR,    
         T.State_ADDR,    
         T.TypeOthp_CODE,    
         RowCount_NUMB    
    FROM (SELECT M.OtherParty_IDNO,    
                 M.OtherParty_NAME,    
                 M.City_ADDR,    
                 M.State_ADDR,    
                 M.TypeOthp_CODE,    
                 M.RowCount_NUMB,    
                 M.ORD_ROWNUM    
            FROM (SELECT K.OtherParty_IDNO,    
                                 K.OtherParty_NAME,    
                                 K.City_ADDR,    
                                 K.State_ADDR,    
                                 K.TypeOthp_CODE,    
                                 COUNT(1) OVER() AS RowCount_NUMB,    
                                 ROW_NUMBER() OVER( ORDER BY K.OtherParty_NAME,K.OtherParty_IDNO) AS ORD_ROWNUM    
                            FROM (SELECT X.OtherParty_IDNO,    
                                         X.OtherParty_NAME,    
                                         X.City_ADDR,    
                                         X.State_ADDR,    
                                         X.TypeOthp_CODE   
                                    FROM (SELECT B.OtherParty_IDNO,
                                                 B.OtherParty_NAME,
                                                 B.City_ADDR,    
                                                 B.State_ADDR,    
                                                 B.TypeOthp_CODE,    
                                                 ROW_NUMBER() OVER(PARTITION BY B.OtherParty_IDNO ORDER BY B.TransactionEventSeq_NUMB DESC) AS RecRank_NUMB    
                                            FROM OFIC_Y1 A    
                                                 JOIN OTHP_Y1 B    
                                                  ON A.OtherParty_IDNO = B.OtherParty_IDNO    
                                           WHERE B.OtherParty_NAME >= ISNULL(@As_OtherParty_NAME, B.OtherParty_NAME)    
                                              AND  B.TypeOthp_CODE IN (SELECT  TypeLocation1_CODE  
                                                                        FROM AMNR_Y1  
                                                                        WHERE TypeActivity_CODE= ISNULL(@Ac_TypeActivity_CODE,TypeActivity_CODE)  
                                                                       UNION   
                                                                       SELECT TypeLocation2_CODE  
                                                                        FROM AMNR_Y1  
                                                                        WHERE TypeActivity_CODE= ISNULL(@Ac_TypeActivity_CODE,TypeActivity_CODE))      
                                             AND B.County_IDNO = ISNULL(@An_County_IDNO,B.County_IDNO)) AS X    
                                   WHERE X.RecRank_NUMB = 1    
                                  UNION    
                                  SELECT X.OtherParty_IDNO,    
                                         X.OtherParty_NAME,    
                                         X.City_ADDR,    
                                         X.State_ADDR,    
                                         X.TypeOthp_CODE   
                                    FROM (SELECT B.OtherParty_IDNO,    
                                                 CASE    
                                                  WHEN @Ac_TypeActivity_CODE = @Lc_ActivityTypeHearing_CODE    
                                                        OR B.TypeOthp_CODE = @Lc_SchLocTypeCourt_CODE    
                                                   THEN ISNULL(ISNULL(CAST(B.ReferenceOthp_IDNO AS VARCHAR), @Lc_Empty_TEXT) + CASE    
                                                                                                             WHEN B.ReferenceOthp_IDNO <> @Li_Zero_NUMB    
                                                                                                              THEN ' - '    
                                                                                                            END + B.OtherParty_NAME,B.OtherParty_NAME)    
                                                  ELSE B.OtherParty_NAME    
                                                 END AS OtherParty_NAME,    
                                                 B.City_ADDR,    
                                                 B.State_ADDR,    
                                                 B.TypeOthp_CODE,    
                                                 ROW_NUMBER() OVER(PARTITION BY B.OtherParty_IDNO ORDER BY B.TransactionEventSeq_NUMB DESC) AS RecRank_NUMB    
                                            FROM OTHP_Y1 B    
                                           WHERE B.TypeOthp_CODE IN (SELECT  TypeLocation1_CODE  
                                                                        FROM AMNR_Y1  
                                                                        WHERE TypeActivity_CODE= ISNULL(@Ac_TypeActivity_CODE,TypeActivity_CODE)  
                                                                        UNION   
                                                                        SELECT TypeLocation2_CODE  
                                                                        FROM AMNR_Y1  
                                                                        WHERE TypeActivity_CODE= ISNULL(@Ac_TypeActivity_CODE,TypeActivity_CODE))     
                                            AND B.TypeOthp_CODE != @Lc_SchLocTypeOffice_CODE    
                                             AND B.OtherParty_NAME >= ISNULL(@As_OtherParty_NAME, B.OtherParty_NAME)    
                                              AND B.County_IDNO = ISNULL(@An_County_IDNO,B.County_IDNO)) AS X    
                                   WHERE X.RecRank_NUMB = 1) AS K ) AS M    
           WHERE M.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS T    
   WHERE ORD_ROWNUM >= @Ai_RowFrom_NUMB    
   ORDER BY ORD_ROWNUM;    
 END; --END OF OTHP_RETRIEVE_S78  
GO
